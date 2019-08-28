# Named Entity Recognition Module {#named-entity-recognition-module}

There are two different modules able to perform NE recognition. They can be instantiated directly, or via a wrapper that will create the right module depending on the configuration file.

The API for the wrapper is the following:

```C++
class ner {
  public:
    /// Constructor
    ner(const std::wstring &cfgfile);
    /// Destructor
    ~ner();

    /// analyze given sentence
    void analyze(sentence &s) const;

    /// analyze given sentences
    void analyze(std::list<sentence> &ls) const;

    /// analyze sentence, return analyzed copy
    sentence analyze(const sentence &s) const;

    /// analyze sentences, return analyzed copy
    std::list<sentence> analyze(const std::list<sentence> &ls) const;
};
```

The parameter to the constructor is the absolute name of a configuration file, which must contain the desired module type (`basic` or `bio`) in a line enclosed by the tags `<Type>` and `</Type>`.

The rest of the file must contain the configuration options specific for the selected NER type, described below.

The `basic` module is simple and fast, and easy to adapt for use in new languages, provided capitalization is the basic clue for NE detection in the target language. The estimated performance of this module is about 85% correctly recognized named entities.

The `bio`  module, is based on machine learning algorithms. It has a higher precision (over 90%), but it is remarkably slower than `basic`, and adaptation to new languages requires a training corpus plus some feature engineering.



## Basic NER module (`np`) {#basic-ner-module-np}

The first NER module is the `np` class, which is a just an ATN that basically detects sequences of capitalized words, taking into account some functional words (e.g. _Bank of England_) and capitalization at sentence begginings.

It can be instantiated via the `ner` wrapper described above, or directly via its own API:

```C++
class np: public ner_module, public automat {
  public:
    /// Constructor, receives a configuration file.
    np(const std::string &cfgfile); 

    /// Detect multiwords starting at given sentence position
    bool matching(sentence &s, sentence::iterator &p) const;

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

The file that controls the behaviour of the simple NE recognizer consists of the following sections:

*   Section `<FunctionWords>` lists the function words that can be embeeded inside a proper noun (e.g. preposisions and articles such as those in _Banco de España_ or _Foundation for the Eradication of Poverty_). For instance:

    ```XML
    <FunctionWords>
    el
    la
    los
    las
    de
    del
    para
    </FunctionWords>
    ```

*   Section `<SpecialPunct>` lists the PoS tags (according to [punctuation tags definition file](punct.md)) after which a capitalized word may be indicating just a sentence or clause beggining and not necessarily a named entity. Typical cases are colon, open parenthesis, dot, hyphen..

    ```XML
    <SpecialPunct>
    Fpa
    Fp
    Fd
    Fg
    </SpecialPunct>
    ```

*   Section `<NE_Tag>` contains only one line with the PoS tag that will be assigned to the recognized entities. If the NE classifier is going to be used later, it will have to be informed of this tag at creation time.

    ```XML
    <NE_Tag>
    NP00000
    </NE_Tag>
    ```

*   Section `<Ignore>` contains a list of forms (lowercased) or PoS tags (uppercased) that are not to be considered a named entity even when they appear capitalized in the middle of a sentence. For instance, that can be used if the word _Spanish_ in the sentence _He started studying Spanish two years ago_ should not be considered named entity. If the words in the list appear with other capitalized words, they are considered to form a named entity (e.g. _An announcement of the Spanish Bank of Commerce was issued yesterday_). The same distinction applies to the word _I_ in sentences such as: _whatever you say, I don't believe_, or _That was the death of Henry I_.

    Each word or tag is followed by a 0 or 1 indicating whether the ignore condition is strict (0: non-strict, 1: strict). The entries marked as non-strict will have the behaviour described above. The entries marked as strict will never be considered named entities or NE parts.

    For instance, the following `<Ignore>` section states that the word _I_ is not to be a proper noun (e.g. _whatever you say, I don't believe_) unless some of its neighbour words are (e.g. _That was the death of Henry I_). It also states that any word with the <tt>RB</tt> tag, and any of the listed language names must never be considered as possible NEs.

    ```XML
    <Ignore>
    i  0
    RB 1
    english 1
    dutch 1
    spanish 1
    </Ignore>
    ```

*   Section `<Names>` contains a list of lemmas that may be names, even if they conflict with some of the heuristic criteria used by the NE recognizer. This is useful when they appear capitalized at sentence beggining. For instance, the basque name _Miren_ (_Mary_) or the nickname _Pelé_ may appear at the beggining of a Spanish sentence. Since both of them are verbal forms in Spanish, they would not be considered candidates to form named entities.

    Including the form in the `<Names>` section, causes the NE choice to be added to the possible tags of the form, giving the tagger the chance to decide whether it is actually a verb or a proper noun.

    ```XML
    <Names>
    miren
    pelé
    zapatero
    china
    </Names>
    ```

*   Section `<Affixes>` contains a list of words that may be part of a NE -either prefixing or suffixing it- even if they are lowercased. For instance, this is the case of the word _don_ in Spanish (e.g. _don Juan_ should be a NE, even if _don_ is lowercased), or the words _junior_ or _jr._ in English (e.g. _Peter Grasswick jr._ should be a NE, even if _jr._ is lowercased).

    The section should containt a word per line, followed by the keyword <tt>PRE</tt> or <tt>SUF</tt> stating whether the word may be attached before or after an NE. It a word should be either a prefix or a suffix, it must be declared in two different lines, one with each keyword.

    ```XML
    <pre><Affixes>
    don  PRE
    doña PRE
    jr.  SUF
    <Affixes>
    ```

*   Sections `<RE_NounAdj>` `<RE_Closed>` and `<RE_DateNumPunct>` allow to modify the default regular expressions for Part-of-Speech tags. This regular expressions are used by the NER to determine whether a sentence-beginning word has some tag that is Noun or Adj, or any tag that is a closed category, or one of date/punctuation/number. The default is to check against Eagles tags, thus, the recognizer will fail to identifiy these categories if your dictionary uses another tagset, unless you specify the right patterns to look for.

    For instance, if our dictionary uses Penn-Treebank-like tags, we should define:

    ```XML
    <pre><RE_NounAdj>
    ^(NN$|NNS|JJ)
    </RE_NounAdj>
    <RE_Closed>
    ^(D|IN|C)
    </RE_Closed>
    ```

*   Section `<TitleLimit>` contains only one line with an integer value stating the length beyond which a sentence written _entirely_ in uppercase will be considered a title and not a proper noun. Example:

    ```XML
    <TitleLimit>
    3
    </TitleLimit>
    ```

    If `TitleLimit=0` (the default) title detection is deactivated (i.e, all-uppercase sentences are always marked as named entities).

    The idea of this heuristic is that newspaper titles are usually written in uppercase, and tend to have at least two or three words, while named entities written in this way tend to be acronyms (e.g. IBM, DARPA, ...) and usually have at most one or two words.

    For instance, if `TitleLimit=3` the sequence _FREELING ENTERS NASDAC UNDER CLOSE OBSERVATION OF MARKET ANALYSTS_ will not be recognized as a named entity, and will have its words analyzed independently. On the other hand, the sequence _IBM INC._, having less than 3 words, will be considered a proper noun.

    Obviously this heuristic is not 100% accurate, but in some cases (e.g. if you are analyzing newspapers) it may be preferrable to the default behaviour (which is not 100% accurate, either).


## BIO NER module (<tt>bioner</tt>) {#bio-ner-module-bioner}

The machine-learning based NER module uses a classification algorithm to decide whether each word is at a NE begin (<tt>B</tt>), inside (<tt>I</tt>) or outside (<tt>O</tt>). Then, Viterbi algorithm is applied to guarantee sequence coherence.

It can be instantiated via the <tt>ner</tt> wrapper described above, or directly via its own API:

```C++
class bioner: public ner_module {
  public:
    /// Constructor, receives the name of the configuration file.
    bioner ( const std::string & );

    /// analyze given sentence.
    void analyze(sentence &) const;

    /// analyze given sentences.
    void analyze(std::list<sentence> &) const;

    /// return analyzed copy of given sentence
    sentence analyze(const sentence &) const;

    /// return analyzed copy of given sentences
    std::list<sentence> analyze(const std::list<sentence> &) const;
};
```

The configuration file sets the required model and lexicon files, which may be generated from a training corpus using the scripts provided with FreeLing.  

Check file [`src/utilities/train-nerc/README`](https://github.com/TALP-UPC/FreeLing/blob/master/src/utilities/train-nerc/README) and comments in the scripts to find out how to retrain the models and what is the meaning of each file.

The most important file in the set is the `.rgf` file, which contains a definition of the context features that must be extracted for each named entity. The feature rule language is described in the [Feature Extractor](fex.md) section.

The sections of the configuration file for bioner module are:

*   Section `<RGF>` contains one line with the path to the RGF file of the model. This file is the definition of the features that will be taken into account for NER.

    ```XML
    <RGF>
    ner.rgf
    </RGF>
    ```


*   Section `<Classifier>` contains one line with the kind of classifier to use. Valid values are `AdaBoost` and `SVM`.

    ```XML
    <Classifier>
    Adaboost
    </Classifier>
    ```

*   Section `<ModelFile>` contains one line with the path to the model file to be used. The model file must match the classifier type given in section `<Classifier>`.

    ```XML
    <ModelFile>
    ner.abm
    </ModelFile>
    ```

    The `.abm` files contain AdaBoost models based on shallow Decision Trees (see [\[CMP03\]](../references.md) for details). You don't need to understand this, unless you want to enter into the code of the AdaBoost classifier.

    The `.svm` files contain Support Vector Machine models generated by <tt>libsvm</tt> [\[CL11\]](../references.md). You don't need to understand this, unless you want to enter into the code of <tt>libsvm</tt>.

*   Section `<Lexicon>` contains one line with the path to the lexicon file of the learnt model. The lexicon is used to translate string-encoded features generated by the extractor to integer-encoded features needed by the classifier. The lexicon file is generated at training time.

    ```XML
    <Lexicon>
    ner.lex
    </Lexicon>
    ```

    The `.lex` file is a dictionary that assigns a number to each symbolic feature used in the AdaBoost or SVM model. You don't need to understand this either unless you are a Machine Learning student or the like.

*   Section `<UseSoftMax>` contains only one line with `yes` or `no`, indicating whether the classifier output must be converted to probabilities with the SoftMax function. Currently, AdaBoost models need that conversion, and SVM models do not.

    ```XML
    <UseSoftMax>
    yes
    </UseSoftMax>
    ```

*   Section `<Classes>` contains only one line with the classes of the model and its translation to <tt>B</tt>, <tt>I</tt>, <tt>O</tt> tag.

    ```XML
    <Classes>
    0 B 1 I 2 O
    </Classes>
    ```

*   Section `<NE_Tag>` contains only one line with the PoS tag that will be assigned to the recognized entities. If the NE classifier is going to be used later, it will have to be informed of this tag at creation time.

    ```XML
    <NE_Tag>
    NP00000
    </NE_Tag>
    ```

*   Section `<InitialProb>` Contains the probabilities of seeing each class at the begining of a sentence. These probabilities are necessary for the Viterbi algorithm used to annotate NEs in a sentence.

    ```XML
    <InitialProb>
    B 0.200072
    I 0.0
    O 0.799928
    </InitialProb>
    ```

*   Section `<TransitionProb>` Contains the transition probabilities for each class to each other class, used by the Viterbi algorithm.

    ```XML
    <TransitionProb>
    B B 0.00829346
    B I 0.395481
    B O 0.596225
    I B 0.0053865
    I I 0.479818
    I O 0.514795
    O B 0.0758838
    O I 0.0
    O O 0.924116
    </TransitionProb>
    ```

*   Section `<TitleLimit>` contains only one line with an integer value stating the length beyond which a sentence written _entirely_ in uppercase will be considered a title and not a proper noun.

    See description of the same option for `basic` named entity recognizer above.