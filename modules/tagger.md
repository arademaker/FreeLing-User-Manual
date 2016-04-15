# Part-of-Speech Tagger Module {#part-of-speech-tagger-module}

There are two different modules able to perform PoS tagging. The application should decide which method is to be used, and instantiate the right class.

The first PoS tagger is the `hmm_tagger` class, which is a classical trigam Markovian tagger, following [\[Bra00\]](../references.md).

The second module, named `relax_tagger`, is a hybrid system capable to integrate statistical and hand-coded knowledge, following [\[Pad98\]](../references.md).

The `hmm_tagger` module is somewhat faster than `relax_tagger`, but the later allows you to add manual constraints to the model. Its API is the following:

Both classes are derived from the `POS_tagger` abstract class:
```C++
class POS_tagger {
  public:
    POS_tagger(bool,unsigned int);
    virtual ~POS_tagger() {};

    /// Do actual disambiguation
    virtual void annotate(sentence &) const =0;

    /// analyze given sentence.
    virtual void analyze(sentence &s) const;

    /// analyze given sentences.
    virtual void analyze(std::list<sentence> &ls) const;

    /// return analyzed copy of given sentence
    virtual sentence analyze(const sentence &s) const;

    /// return analyzed copy of given sentences
    virtual std::list<sentence> analyze(const std::list<sentence> &ls) const;
};
```

Other PoS methods can be added deriving new classes from `POS_tagger`.


## Hidden Markov Model PoS Tagger

The `hmm_tagger` implements a classical trigam Markovian tagger. 

Its API is:
```C++
class hmm_tagger: public POS_tagger {
  public:
    /// Constructor
    hmm_tagger(const std::string &hmmfile, 
               bool retok, 
               unsigned int force, 
               unsigned int kb=1);

    /// analyze given sentence.
    void analyze(sentence &s) const;

    /// analyze given sentences.
    void analyze(std::list<sentence> &ls) const;

    /// return analyzed copy of given sentence
    sentence analyze(const sentence &s) const;

    /// return analyzed copy of given sentences
    std::list<sentence> analyze(const std::list<sentence> &ls) const;

    /// given an analyzed sentence find out probability 
    /// of the k-th best sequence
    double SequenceProb_log(const sentence &s, int k=0) const;
};
```

The `hmm_tagger` constructor receives the following parameters:

*   The HMM file, which containts the model parameters. The format of the file is described below. This file can be generated from a tagged corpus using the script `src/utilities/train-tagger/bin/TRAIN.sh` provided in FreeLing package. See `src/utilities/train-tagger/README` to find out the details.
*   A boolean stating whether words that carry retokenization information (e.g. set by the dictionary or affix handling modules) must be retokenized (that is, splitted in two or more words) after the tagging.
*   An integer stating whether and when the tagger must select only one analysis in case of ambiguity. Possbile values are: `FORCE_NONE` (or 0): no selection forced, words ambiguous after the tagger, remain ambiguous. `FORCE_TAGGER` (or 1): force selection immediately after tagging, and before retokenization. `FORCE_RETOK` (or 2): force selection after retokenization.
*   An integer stating how many best tag sequences the tagger must try to compute. If not specified, this parameter defaults to 1. Since a sentence may have less possible tag sequences than the given _k_ value, the results may contain a number of sequences smaller than _k_.


### HMM-Tagger Parameter File {#hmm-tagger-parameter-file}

This file contains the statistical data for the Hidden Markov Model, plus some additional data to smooth the missing values. Initial probabilities, transition probabilities, lexical probabilities, etc.

The file may be generated by your own means, or using a tagged corpus and the training script provided in FreeLing package: `src/utilities/train-tagger/bin/TRAIN.sh`. See `src/utilities/train-tagger/README` for details.

The file has eight sections which contain -among other things- the paremeters of the HMM (e.g. the tag (unigram), bigram, and trigram probabilities used in Linear Interpolation smoothing by the tagger to compute state transition probabilities ( _α_<sub>ij</sub> parameters of the HMM):

*   Section `<TagsetFile>`. This section contains a single line with the path to a [tagset description](tagset.md) file to be used when computing short versions for PoS tags. If the path is relative, the location of the lexical probabilities file is used as the base directory.  
    This section has to appear before section `<Forbidden>`.

*   Section `<Tag>`. List of unigram tag probabilities (estimated via your preferred method). Each line is a tag probability _P(t)_ with format   
    `Tag Probability`  
    Lines for tags `0` (sentence beginning) and `x` (unobserved tags) must be included.  
    E.g.  
    ```
    0 0.03747
    AQ 0.00227
    NC 0.18894
    x 1.07312e-06
    ```

*   Section `<Bigram>`. List of bigram transition probabilities (estimated via your preferred method). Each line is a transition probability, with the format:   
    `Tag1.Tag2 Probability` 
    Tag `0` (zero) indicates sentence-begining.

    E.g.:   
    * The following line indicates the transition probability between a sentence start and the tag of the first word being `AQ`.  
    `0.AQ 0.01403`
    * The following line indicates the transition probability between two consecutive tags.   
    `AQ.NC 0.16963`

*   Section `<Trigram>`. List of trigram transition probabilities (estimated via your preferred method). 
    Each line is a transition probability, with the format:   
    `Tag1.Tag2.Tag3 Probability`  
    Tag `0` (zero) indicates sentence-begining.

    E.g.:
    * The following line indicates the probability that a word has `NC` tag just after a `0.AQ` sequence.   
    `0.AQ.NC 0.204081`
    * The following line indicates the probability of a tag `SP` appearing after two words tagged `DA` and `NC`.   
    `DA.NC.SP 0.33312` 

*   Section `<Initial>`. List of initial state probabilities (estimated via your preferred method), i.e. the _π_<sub>i</sub> parameters of the HMM. Each line is an initial probability, with the format:  
    `InitialState LogProbability`

    Each `InitialState` is a PoS-bigram code with the form `0.tag`. Probabilities are given in logarithmic form to avoid underflows.

    E.g.:
    * The following line indicates the probability that the sequence starts with a determiner.   
    `0.DA -1.744857`
    * The following line indicates the probability that the sequence starts with an unknown tag.    
    `0.x -10.462703`

*   Section `<Word>`. Contains a list of word probabilities _P(w)_ (estimated via your preferred method). It is used, toghether with the tag probabilities above, to compute emission probabilities (_b_<sub>iw</sub> parameters of the HMM).

    Each line is a word probability _P(w)_ with format: `word LogProbability`.   
    A special line for `<UNOBSERVED_WORD>` must be included.  
    Sample lines for this section are:
    ```
    afortunado -13.69500
    sutil -13.57721
    <UNOBSERVED_WORD> -13.82853
    ```

*   Section `<Smoothing>` contains three lines with the coefficients used for linear interpolation of unigram (`c1`), bigram (`c2`), and trigram (`c3`) probabilities. The section looks like:  
    ```XML    
    <Smoothing>
    c1 0.120970620869314
    c2 0.364310868831106
    c3 0.51471851029958
    </Smoothing>
    ```

*   Section `<Forbidden>` is the only that is not generated by the training scripts, and is supposed to be manually added (if needed). The utility is to prevent smoothing of some combinations that are known to have zero probability.

    Lines in this section are trigrams, in the same format than above: `Tag1.Tag2.Tag3`

    Trigrams listed in this section will be assigned zero probability, and no smoothing will be performed. This will cause the tagger to avoid any solution including these subsequences.

    The first tag may be a wildcard (`*`), which will match any tag, or the tag `0` which denotes sentence beginning. These two special tags can only be used in the first position of the trigram.

    In the case of an EAGLES tagset, the tags in the trigram may be either the short or the long version. The tags in the trigram (except the special tags `*` and `0`) can be restricted to a certain lemma, suffixing them with the lemma in angle brackets.

    For instance, the following rules will assign zero probability to any sequence containing the specified trigram:
    * `*.PT.NC`: a noun after an interrogative pronoun. 
    * `0.DT.VMI`: a verb in indicative following a determiner just after sentence beggining. 
    * `SP.PP.NC`: a noun following a preposition and a personal pronoun.

    Similarly, the set of rules:
    ```
    *.VAI<haber>.NC
    *.VAI<haber>.AQ
    *.VAI<haber>.VMP00SF
    *.VAI<haber>.VMP00PF
    *.VAI<haber>.VMP00PM
    ```
    will assign zero probability to any sequence containing the verb _haber_ (_to have_) tagged as an auxiliar (`VAI`) followed by any of the listed tags. Note that the masculine singular participle is not excluded, since it is the only allowed after an auxiliary _haber_. This will force the tagger to pick the `VM` tag for _haber_ when it is not followed by a masculine singular participle.


## Relaxation Labelling PoS Tagger

The `relax_tagger` module can be tuned with hand written constraint, but it has under half the speed of `hmm_tagger`. It is not able to produce _k_ best sequences. The advantadges it offers is the ability to biass/correct the model adding linguistically mootivated manual constraints.

```C++
class relax_tagger : public POS_tagger {
  public:
    /// Constructor, given the constraint file and config parameters
    relax_tagger(const std::string &cfgfile, 
                 int m, 
                 double f, 
                 double r, 
                 bool retok, 
                 unsigned int force);

    /// analyze given sentence.
    void analyze(sentence &s) const;

    /// analyze given sentences.
    void analyze(std::list<sentence> &ls) const;

    /// return analyzed copy of given sentence
    sentence analyze(const sentence &s) const;

    /// return analyzed copy of given sentences
    std::list<sentence> analyze(const std::list<sentence> &ls) const;
};
```

The `relax_tagger` constructor receives the following parameters:

*   The constraint file. The format of the file is described below. This file can be generated from a tagged corpus using the script `src/utilities/train-tagger/bin/TRAIN.sh` provided in FreeLing package. See `src/utilities/train-tagger/README` for details.
*   An integer `m` stating the maximum number of iterations to wait for convergence before stopping the disambiguation algorithm.
*   A real number `f` representing the scale factor of the constraint weights.
*   A real number `r` representing the threshold under which any changes will be considered too small. Used to detect convergence.
*   A boolean `retok` stating whether words that carry retokenization information (e.g. set by the dictionary or affix handling modules) must be retokenized (that is, splitted in two or more words) after the tagging.
*   An integer stating whether and when the tagger must select only one analysis in case of ambiguity. Possbile values are: `FORCE_NONE` (or 0): no selection forced, words ambiguous after the tagger, remain ambiguous. `FORCE_TAGGER` (or 1): force selection immediately after tagging, and before retokenization. `FORCE_RETOK` (or 2): force selection after retokenization.

The iteration number, scale factor, and threshold parameters are very specific of the relaxation labelling algorithm. Refer to [\[Pad98\]](../references.md) for details.


### Relaxation-Labelling Constraint Grammar File {#relaxation-labelling-constraint-grammar-file}

The syntax of the file is based on that of Constraint Grammars [\[KVHA95\]](../references.md), but simplified in many aspects, and modified to include weighted constraints.

An initial file based on statistical constraints may be generated from a tagged corpus using the `src/utilities/train-tagger/bin/TRAIN.sh` script provided with FreeLing. Later, hand written constraints can be added to the file to improve the tagger behaviour.

The file consists of two sections: `SETS` and `CONSTRAINTS`.

#### Set definition {#set-definition}

The `SETS` section consists of a list of set definitions, each of the form:  
`Set-name = element1 element2 ... elementN;`

Where the `Set-name` is any alphanumeric string starting with a capital letter, and the elements are either forms, lemmas, plain PoS tags, or senses. Forms are enclosed in parenthesis -e.g. `(comimos)`-, lemmas in angle brackets -e.g. `<comer>`-, PoS tags are alphanumeric strings starting with a capital letter -e.g. `NCMS000`-, and senses are enclosed in square brackets -e.g. `[00794578]`. The sets must be homogeneous: That is, all the elements of a set have to be of the same kind.

Examples of set definitions:  
```
DetMasc = DA0MS0 DA0MP0 DD0MS0 DD0MP0 DI0MS0 DI0MP0 DP1MSP DP1MPP
          DP2MSP DP2MPP DT0MS0 DT0MP0 DE0MS0 DE0MP0 AQ0MS0 AQ0MP0;
VerbPron = <dar_cuenta> <atrever> <arrepentir> <equivocar> <inmutar>
           <morir> <ir> <manifestar> <precipitar> <referir> <venir>;
Animal = [00008019] [00862484] [00862617] [00862750] [00862871] [00863425]
         [00863992] [00864099] [00864394] [00865075] [00865379] [00865569]
         [00865638] [00867302] [00867448] [00867773] [00867864] [00868028]
         [00868297] [00868486] [00868585] [00868729] [00911889] [00985200]
         [00990770] [01420347] [01586897] [01661105] [01661246] [01664986] 
         [01813568] [01883430] [01947400] [07400072] [07501137];
```

#### Constraint definition {#constraint-definition}

The `CONSTRAINTS` section consists of a series of context constraits, each of the form:   
`weight core context;`  

Where:
*   `weight` is a real value stating the compatibility (or incompatibility if negative) degree of the core `label` with the `context`.
*   `core` indicates the analysis or analyses in a word that will be affected by the constraint. It may be:
    *   Plain tag: A plain complete PoS tag, e.g. `VMIP3S0`
    *   Wildcarded tag: A PoS tag prefix, right-wilcarded, e.g. `VMI*`, `VMIP*`.
    *   Lemma: A lemma enclosed in angle brackets, optionaly preceded by a tag or a wildcarded tag. e.g. `<comer>`, `VMIP3S0<comer>`, `VMI*<comer>` will match any word analysis with those tag/prefix and lemma.
    *   Form: Form enclosed in parenthesis, preceded by a PoS tag (or a wilcarded tag). e.g. `VMIP3S0(comió)`, `VMI*(comió)` will match any word analysis with those tag/prefix and form. Note that the form alone is not allowed in the rule core, since the rule would not distinguish among different analysis of the same form.
    *   Sense: A sense code enclosed in square brackets, optionaly preceded by a tag or a wildcarded tag. e.g. `[00862617]`, `NCMS000[00862617]`, `NC*[00862617]` will match any word analysis with those tag/prefix and sense.
*   `context` is a list of conditions that the context of the word must satisfy for the constraint to be applied. Each condition is enclosed in parenthesis and the list (and thus the constraint) is finished with a semicolon. Each condition has the form:   
`(position terms)`   
or either:   
`(position terms barrier terms)`
`(position terms barrier terms)`  
Conditions may be negated using the token not, i.e.  
`(not pos terms)`  
`(not position terms barrier terms)`

    Where:
    *   `position` is the relative position where the condition must be satisfied: `-1` indicates the previous word and `+1` the next word. A position with a star (e.g. `-2*`) indicates that any word is allowed to match starting from the indicated position and advancing towards the beggining/end of the sentence.
    *   `terms` is a list of one or more terms separated by the token `or`. Each term may be:
        *   Plain tag: A plain complete PoS tag, e.g. `VMIP3S0`
        *   Wildcarded tag: A PoS tag prefix, right-wilcarded, e.g. `VMI*`, `VMIP*`.
        *   Lemma: A lemma enclosed in angle brackets, optionaly preceded by a tag or a wildcarded tag. e.g. `<comer>`, `VMIP3S0<comer>`, `VMI*<comer>` will match any word analysis with those tag/prefix and lemma.
        *   Form: Form enclosed in parenthesis, optionally preceded by a PoS tag (or a wilcarded tag). e.g. `(comió)`, `VMIP3S0(comió)`, `VMI*` will match any word analysis with those tag/prefix and form. Note that -contrarily to when defining the rule core- the form alone is allowed in the context.
        *   Sense: A sense code enclosed in square brackets, optionaly preceded by a tag or a wildcarded tag. e.g. `[00862617]`, `NCMS000[00862617]`, `NC*[00862617]` will match any word analysis with those tag/prefix and sense.
        *   Set reference: A name of a previously defined SET in curly brackets. e.g. `{DetMasc}`, `{VerbPron}` will match any word analysis with a tag, lemma or sense in the specified set.
    *   `barrier` inhibits the application of the rule if a match for the associated term conditions is found between the focus word and the word matching the rule conditions.


Note that the use of sense information in the rules of the constraint grammar (either in the core or in the context) only makes sense when this information distinguishes one analysis from another. If the sense tagging has been performed with the option `DuplicateAnalysis=no`, each PoS tag will have a list with all analysis, so the sense information will not distinguish one analysis from the other (there will be only one analysis with that sense, which will have at the same time all the other senses as well). If the option `DuplicateAnalysis` was active, the sense tagger duplicates the analysis, creating a new entry for each sense. So, when a rule selects an analysis having a certain sense, it is unselecting the other copies of the same analysis with different senses.

### Examples {#examples}

The next constraint states a high incompatibility for a word being a definite determiner (`DA*`) if the next word is a personal form of a verb (`VMI*`):   
```
-8.143 DA*  
       (1 VMI*);
```

The next constraint states a very high compatibility for the word _mucho_ (_much_) being an indefinite determiner (`DI*`) -and thus not being a pronoun or an adverb, or any other analysis it may have- if the following word is a noun (`NC*`):  
```
60.0 DI*(mucho)
     (1 NC*);
```

The next constraint states a positive compatibility value for a word being a noun (`NC*`) if somewhere to its left there is a determiner or an adjective (`DA* or AQ*`), and between them there is not any other noun:   
```
5.0 NC* 
    (-1* DA* or AQ* barrier NC*);
```

The next constraint states a positive compatibility value for a word being a masculine noun (`NCM*`) if the word to its left is a masculine determiner. It refers to a previously defined SET which should contain the list of all tags that are masculine determiners. This rule could be useful to correctly tag Spanish words which have two different NC analysis differing in gender: e.g. _el cura_ (_the priest_) vs. _la cura_ (_the cure_):   
```
5.0 NCM* 
    (-1* DetMasc);
```

The next constraint adds some positive compatibility to a 3rd person personal pronoun being of undefined gender and number (`PP3CNA00`) if it has the possibility of being masculine singular (`PP3MSA00`), the next word may have lemma _estar_ (_to be_), and the second word to the right is not a gerund (`VMG*`). This rule is intended to solve the different behaviour of the Spanish clitic pronoun _lo_ (it) in sentences such as _¿Cansado? Si, lo estoy._ (_Tired? Yes, I am [it]_) or _lo estoy viendo._ (_I am watching it_). 
```
0.5 PP3CNA00 
    (0 PP3MSA00) 
    (1 <estar>) 
    (not 2 VMG*);
```