# Probability Assignment and Unknown Word Guesser Module {#probability-assignment-and-unknown-word-guesser-module}

This class ends the morphological analysis subchain, and has two functions: first, it assigns an a priori probability to each analysis of each word. These probablities will be needed for the PoS tagger later. Second, if a word has no analysis (none of the previously applied modules succeeded to analyze it), this module tries to guess which are its possible PoS tags, based on the word ending.

```C++
class probabilities {
  public:
    /// Constructor: receives the name of the file
    // containing probabilities, and a threshold.
    probabilities(const std::string &cfgfile, double thresh);

    /// Assign probabilities for each analysis of given word
    void annotate_word(word &w) const;

    /// Turn guesser on/of
    void set_activate_guesser(bool b);

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

The method `set_activate_guesser` will turn on/off the guessing of likely PoS tags for words with no analysis. Note that the guesser is turned on/off for any thread using the same probabilities instance.

The constructor receives:

*   The probabilities file name: The file that contains all needed configuration and statistical information. This file can be generated from a tagged training corpus using the scripts in `src/utilities/train-tagger`. Its format is described below.
*   A threshold: This is used for unknown words, when the probability of each possible tag has been estimated by the guesser according to word endings, tags with a value lower than this threshold are discarded.

## Lexical Probabilities File {#lexical-probabilities-file}

This file can be generated from a tagged corpus using the training script provided in FreeLing package, located at `src/utilities/train-tagger/bin/TRAIN.sh`.

See `src/utilities/train-tagger/README` to find out how to use it.

The probabilities file has the following sections:

*   Optional section `<LemmaPreferences>` and contains a list of pairs of lemmas. The meaning of each pair is that the first element is prefereble to the second in case the tagger can not decide between them and is forced to.

    For instance, the section:
    ```XML
    <LemmaPreferences>
    salir salgar
    </LemmaPreferences>
    ```

    solves the ambiguity for Spanish word salgo, which may correspond to indicative first person singular of verb salir (go out), or to exactly the same tense of verb salgar (feed salt to cattle). Since the PoS tag is the same for both lemmas, the tagger can not decide which is the right one. This preference solves the dilemma in favour of salir (go out), which is more frequent.

*   Optional section `<PoSPreferences>` and contains a list of pairs of PoS tags. The meaning of each pair is that the first element is prefereble to the second in case the tagger can not decide between them and is forced to. The POS preference is only used when the tie can not be solved using lemma preferences.

    For instance, the section
    ```XML
    <PosPreferences>
    VMII3S0 VMII1S0
    </PosPreferences>
    ```

    helps solving cases as the past tense for Spanish verbs such as cantaba (I/he sung), which are shared by first and third person. In this case, if the tagger is not able to make a decision a preference is set for 3rd person (which is more frequent in standard text).

*   Section `<TagsetFile>`: This section contains a single line with the path to a [tagset description](tagset.md) file to be used when computing short versions for PoS tags. If the path is relative, the location of the lexical probabilities file is used as the base directory.

*   Section `<FormTagFreq>`: Probability data of some high frequency forms.

    If the word is found in this list, lexical probabilities are computed using data in `<FormTagFreq>` section.

    The list consists of one form per line, each line with format:  
    `form ambiguity-class, tag1 #observ1 tag2 #observ2 ...`  
    E.g.:  
    `japonesas AQ-NC AQ 1 NC 0` 

    Form probabilities are smoothed to avoid zero-probabilities.

*   Section `<ClassTagFreq>`: Probability data of ambiguity classes.

    If the word is not found in the `<FormTagFreq>`, frequencies for its ambiguity class are used.

    The list consists of class per line, each line with format:  
    `class tag1 #observ1 tag2 #observ2 ...`  
    E.g.:  
    `AQ-NC AQ 2361 NC 2077`

    Class probabilities are smoothed to avoid zero-probabilities.

*   Section `<SingleTagFreq>`: Unigram probabilities.

    If the ambiguity class is not found in the `<ClassTagFreq>`, individual frequencies for its possible tags are used.

    One tag per line, each line with format:  
    `tag #observ`   
    E.g.:  
    `AQ 7462`

    Tag probabilities are smoothed to avoid zero-probabilities.

*   Section `<Theeta>`: Value for parameter theeta used in smoothing of tag probabilities based on word suffixes.

    If the word is not found in dictionary (and so the list of its possible tags is unknown), the distribution is computed using the data in the `<Theeta>`, `<Suffixes>`, and `<UnknownTags>` sections.

    The section has exactly one line, with one real number.  
    E.g.
    ```XML
    <Theeta>
    0.00834
    </Theeta>
    ```

*   Section `<BiassSuffixes>`: Weighted interpolation factor between class probability and word suffixes.

    The section has exactly one line, with one real number.  
    E.g. 
    ```XML
    <BiassSuffixes>
    0.4
    </BiassSuffixes>
    ```

    This section is optional. If ommited, used default value is 0.3.

    The probability of the tags belonging to words unobserved in the training corpus, is computed backing off to the distribution of all words with the same ambiguity class. This obviously overgeneralizes and for some words, the estimated probabilities may be rather far from reality.

    To palliate this overgeneralization, the ambiguity class probabilities can me interpolated with the probabilities assigned by the guesser according to the word suffix.

    This parameter specifies the weight that suffix information is given in the iterpolation, i.e. if `BiassSuffixes=0` only the ambiguity class information is used. If `BiassSuffixes=1`, only the probabilities provided by the guesser are used.

*   Section `<Suffixes>`: List of suffixes obtained from a train corpus, with information about which tags were assigned to the word with that suffix.

    The list has one suffix per line, each line with format:  
    `suffix #observ tag1 #observ1 tag2 #observ2 ...`  
    E.g.  
    `orada 133 AQ0FSP 17 VMP00SF 8 NCFS000 108` 

*   Section `<UnknownTags>`: List of open-category tags to consider as possible candidates for any unknown word.

    One tag per line, each line with format:  
    `tag #observ`   
    The tag is the complete label. The count is the number of occurrences in a training corpus.  
    E.g.  
    `NCMS000 33438`

*   Section `<LidstoneLambdaLexical>`: specifies the _λ_ parameter for Lidstone's Law smoothing of seen words

    The section has exactly one line, with one real number.  
    E.g. 
    ```XML
    <LidstoneLambdaLexical>
    0.2
    </LidstoneLambdaLexical>
    ```

    This section is optional. If ommited, used default value is 0.1.

    This parameter is used only to smooth the lexical probabilities of words that have appeared in the training corpus, and thus are listed in the `<FormTagFreq>` section described above.

*   Section `<LidstoneLambdaClass>` specifies the _λ_ parameter for Lidstone's Law smoothing of unseen words

    The section has exactly one line, with one real number.
    E.g. 
    ```XML
    <LidstoneLambdaLexical>
    0.5
    </LidstoneLambdaLexical>
    ```

    This section is optional. If ommited, used default value is 0.1.

    This parameter is used only to smooth the lexical probabilities of words that have not appeared in the training corpus, and thus are not listed in the `<FormTagFreq>` section. In these cases, information from appropriate ambiguity class in `<ClassTagFreq>` section is used.
