
# Feature Extraction Module {#feature-extraction-module}

Machine Learning based modules (such as BIO named entity recognition or classification modules) require the encoding of each word to classify as a feature vector. The conversion of words in a sentence to feature vectors, is performed by this module. The features are task-oriented, so they vary depending on what is being classified. For this reason, the encoding is not hard-wired in the code, but dinamically performed interpreting a set of feature rules.

Thus, the Feature Extraction Module converts words in a sentence to feature vectors, using a given set of rules.

The API of this module is the following:

```C++
class fex {
  private:

  public:
    /// constructor, given rule file, lexicon file (may be empty),
    /// and custom functions
    fex(const std::wstring&, const std::wstring&, 
        const std::map<std::wstring,const feature_function *> &);

    /// encode given sentence in features as feature names. 
    void encode_name(const sentence &, std::vector<std::set<std::wstring> > &);
    /// encode given sentence in features as integer feature codes
    void encode_int(const sentence &, std::vector<std::set<int> > &);
    /// encode given sentence in features as integer feature codes and 
    /// as features names
    void encode_all(const sentence &, std::vector<std::set<std::wstring> > &, 
                    std::vector<std::set<int> > &);

    /// encode given sentence in features as feature names. 
    /// Return result suitable for Java/perl APIs
    std::vector<std::list<std::wstring> > encode_name(const sentence &);
    /// encode given sentence in features as integer feature codes.
    /// Return result suitable for Java/perl APIs
    std::vector<std::set<int> > encode_int(const sentence &);

    /// clear lexicon
    void clear_lexicon(); 
    /// encode sentence and add features to current lexicon
    void encode_to_lexicon(const sentence &);
    /// save lexicon to a file, filtering features with low occurrence rate
    void save_lexicon(const std::wstring &, double) const;
};
```

The class may be used to encode a corpus and generate a feature lexicon, or to encode a corpus filtering the obtained features using a previously generated feature lexicon.

The rules may call custom feature functions, provided the instantianting program provides pointers to call the apropriate code to compute them.

Once the class is instantiated, it can ben used to encode sentences in feature vectors. Features may be obtained as strings (feature names) or integers (feature codes).

The constructor of the class receives a `.rgf` file containing feature extraction rules, a feature lexicon file (mapping feature names to integer codes), and a `map<string,feature_function>` used to define custom feature functions).

If the lexicon file name is empty, features will be assigned an integer code, and the generated lexicon can be saved. This is useful when encoding training corpus and feature codes have not been set yet.

## Feature Extraction Rule File {#feature-extraction-rule-file}

Feature extraction rules are defined in a `.rgf` file. This section describes the format of the file. The syntax of the rules is described further below.

Rules are grouped in packages. Begin and end of a package is marked with the keywords `RULES` and `ENDRULES`. Packages are useful to simplify the rules, and to speed up feature computation avoiding computing the same features several times.

A line with format `TAGSET filename` may precede the rule packages definition. The given `filename` will be interpreted as a relative path (based on the `.rgf` location) to a [tagset definition](tagset.md) file that will be used to obtain short versions of PoS tags. The `TAGSET` line is needed only if the short tag property `t` is used in some rule.

The `RULES` package starting keyword must be followed by a condition on word properties. Rules in a package will onlly be applied to those words matching the package condition, thus avoiding unnecessary tests.

For instance, the rules in the package:
```
RULES t matches ^NP
 ...
ENDRULES
```
will be applied only for words with a PoS tag (`t`) starting with `NP`. The same result could have been obtained without the package if the same condition was added to each rule, but then, applicability tests for each rule on each word would be needed, resulting in a higher computational cost.

The package condition may be `ALL`. In this case, rules contained in the package will be checked for all words in the sentence. This condition has also an extra effect: the features extracted by rules in this package are cached, in order to avoid repeating computations, e.g. if a rule uses a window to get features from neighbour words.

For instance, the rule:
```
RULES ALL
 punct_mark@   [-2,2]   t matches ^F
ENDRULES
```
will generate, for each word, features indicating which words in the surrounding two words (left and right) are punctuation symbols (`F`).

With this rule applied to the sentence "_Hi ! , said John ._" the word _said_ would get the features `punct_mark@-1` (comma to the left of _said_), `punct_mark@-2` (exclamation mark), and `punct_mark@2` (dot after _John_). The word _John_ would get the features `punct_mark@-2` and `punct_mark@1`. Since the package has condition `ALL`, the features are computed once per word, and then reused (that is, the fact that the comma is a punctuation sign will be checked only once, regardless of the size of the sentence and the size of the windows in the rules).

## Rule Syntax {#rule-syntax}

Each rule has following syntax:  
`feature-name-pattern window condition`

*   `feature-name-pattern` is a string that describes what the generated feature name will be. Some special characters allow the insertion of variable values in the feature name. Details on feature patterns are provided below.
*   `window` is a range in the format `[num,num]`, and states the words around the target word for which the feature has to be computed. A window of `[0,0]` means that the feaure is only checked for the target word.
*   `condition` is the condition that a word has to satisfy in order to get the features extracted by the rule. Details on condition sintax are provided below.

## Feature Name Pattern Syntax {#feature-name-pattern-syntax}

Each feature rule has a `feature-name-pattern` that describes how the generated feature name will be.

The following characters are special and are interpreted as variables, and replaced by the corresponding values:

*   Character `@`: will be replaced with the relative position of the matching word with respect to the target word. Thus, the rule `punct_mark@ [-2,2] t matches ^F` will generate a different feature for each word in the window that is a punctuation sign (e.g. `punct_mark@-2` and `punct_mark@1` for the word _John_ in the above example).

    But the rule `punct_mark [-2,2] t matches ^F` will generate the same feature for all words in the window that are punctuation signs, since position is not encoded in the feature pattern (i.e. it will generate `punct_mark` twice for the word _John_ in the above example). Repeated features are stored only once.

*   Character `$` introduces a variable that must have the format: `$var(position)`.

    * Allowed variable names are: `W` (word form, in its original casing), `w` (word form, lowercased), `l` (word lemma), `T` (word full PoS tag), `t` (word short PoS tag), `a` (word lemma+Pos tag). All above variables refer to the analysis selected by the tagger. Variable names may be prefixed with `p` (e.g. `pT`, `pl`, `pa`, etc.) which will generate the feature for all possible analysis of the word, not just the one selected by the tagger.

    * The `position` indicates from which word (relative to the focus word) the value for the variable must be taken.

    For instance, the pattern: `pbig@:$w(0)_$pt(1)` will extract features that will contain the relative position (`@`), plus a bigram made of the word form of the current word in the window (`$w(0)`) plus each possible short PoS tag of the word right of it (`$pt(1)`).

    In the sentence "_John lives here ._", the features for word _here_ in a window of [-2,0] with the above pattern would be: `pbig@-2:john_VBZ` (word form for _John_ plus first possible tag for _lives_), `pbig@-2:john_NNS` (word form for _John_ plus second possible tag for _lives_), `pbig@-1:lives_RB` (word form for _lives_ plus first possible tag for _here_), and `pbig@0:here_Fp` (word form for _here_ plus first tag for the dot). Note that there are two features generated for window position -2 because the word _lives_ has two possible PoS tags.

*   Curly brackets `{ }` have two possible interpretations, depending on what they contain:
    1.  If the brackets enclose a regex match variable (e.g $0, $1, $2, ...), then they are replaced with the string matching the corresponding (sub)expression. This only makes sense if the condition of the rule included a regular expression match. If it is not the case, results are undefined (probably a segmentation violation).
    2.  If the brackets do not contain a regex match variable, then the content is interpreted as call to a custom feature function. It must have the format `{functname(position)}`, where `functname` is the name of the function as declared in the custom feature functions map (see below), and the `position` parameter is the relative position to the target word, and is interpreted in the same way than in the primitive features `$w(position)`, `$t(position)`, etc., described above.   
        E.g., the pattern: `{quoted(-1)}_{quoted(0)}` would generate a feature similar to that of the pattern: `t(-1)_t(0)` but using the result of the custom function `quoted` instead of the PoS tag for the corresponding word.

## Feature Rules Condition Syntax {#feature-rules-condition-syntax}

Conditions control the applicability of a rule or a rule package to a certain word.

A condition may be `ALL` which is satisfied by any word. A condition may be simple, or compund of several conditions, combined with the logical operadors `AND` and `OR`. The operators in a condition must be homogeneous (i.e. either all of them `AND` or all of them `OR`), mixed conditions are not allowed (note that an `OR` condition is equivalent to writing two rules that only differ on the condition).

Single conditions consist of a word property, an operation, and an argument. Available word properties are:
*   `W`: Word form, original casing.
*   `w`: Word form, lowercased.
*   `l`: Lemma of the analysis selected by the tagger.
*   `t`: PoS tag (short version) of the analysis selected by the tagger.
*   `T`: PoS tag (full version) of the analysis selected by the tagger.
*   `pl`: List of all possible lemmas for the word.
*   `pt`: List of all possible short PoS tags for the word.
*   `pT`: List of all possible full PoS tags for the word.
*   `na`: Number of analysis of the word.
*   `u.`_i_: _i_-th element of the word `user` field (see description of [`word` class](../language-classes.md).)

Note that all word properties (including `na`) are either strings or lists of strings.

The available primitive operations to build single conditions are the following:
1.  `<property> is <string>` : String identity.
2.  `<property> matches <regexp>` : Regex match. If the regex is parenthesized, (sub)expression matches `$0`, `$1`, `$2`, etc. are stored and can be used in the feature name pattern.
3.  `<property-list> any_in_set <filename>` (or simply `in_set`): True iff any property in the list is found in the given file.
4.  `<property-list> all_in_set <filename>`: True iff all properties in the list are found in the given file.
5.  `<property-list> some_in_set <filename>`: True iff at least two properties in the list are found in the given file.

Operators can be negated with the character `!`. E.g. `!is`, `!matches`, etc.

For file operators expecting lists, the property may be a single string (list of one element).

Some sample valid conditions:
*   `t is NC`   true if the short version of the tag equals `NC`.
*   `T matches ^NC.S..`   true if the long version of the tag matches the given regular expression.
*   `pl in_set my/data/files/goodlemmas.dat`   rue if any possible lemma for the word is found in the given file.
*   `l !in_set my/data/files/badlemmas.dat`   true if selected lemma for the word is not found in the given file.
*   `w matches ...$`   Always true. Will set the match variable `$0` to the last three characters of the word, so it can be used in the feature name pattern (e.g. to generate a feature with the suffix of each word).

## Adding custom feature functions {#adding-custom-feature-functions}

Custom feature functions can be defined, and called from the `.rgf` file enclosed in curly brackets (e.g.: `{quoted(0)}`). Calls to custom feature functions in the `.rgf` file must have one integer parameter, indicating a word position relative to the target word.

Actual code computing custom feature functions must be provided by the caller. the constructor accepts a parameter containing a map `std::map<std::wstring,const feature_function*>`, associating the custom function name used in the rule file with a `feature_function` pointer.

Custom feature functions must be classes derived from class `feature_function`:
```C++
class feature_function {  
    public: 
      virtual void extract (const sentence &s, 
                            int pos, 
                            std::list<std::wstring> &) const=0;
      /// Destructor
      virtual ~feature_function() {};
  };
```

They must implement a method `extract` that receives the sentence, the position of the target word, and a list of strings where the resulting feature name (or names if more than one is to be generated) will be added.

For instance, the example below generates the feature name `in_quotes` when the target word is surrounded by words with the `Fe` PoS tag (which is assigned to any quote symbol by the punctuation module).
```C++
class fquoted : public feature_function {
    public:
      void extract (const sentence &sent, int i, std::list<std::wstring> &res) const {
        if ( (i>0 and sent[i-1].get_tag()==L"Fe") and
             (i<(int)sent.size()-1 and sent[i+1].get_tag()==L"Fe") )
          res.push_back(L"in_quotes");
      }
  };
```

We can associate this function with the function name `quoted` adding the pair to a map:
```C++
map<wstring,const feature_function*> myfunctions;
myfunctions.insert(make_pair(L"quoted", (feature_function *) new fquoted()));
```

If we now create a `fex` object passing this map to the constructor, the created instance will call `fquoted::extract` with the appropriate parameters whenever `quoted` feature  is used in a rule in the `.rgf` file.  
For instance, we could create the rule:  
`{quoted(0)}@_t(1)   [-5,5]  ALL`   
which will generate a feature with the position and the tag of the word after the quote for any quote in the window `[-5,5]` around the target word (e.g. `in_quotes@-2_NC`, `in_quotes@3_DT`, etc.)

Note that there are three naming levels for custom feature functions:
*   The name of the feature itself, which will be generated by the extractor and will appear in the feature vectors (`in_quotes` in the above example).
*   The name of the function that will be called from the extraction rules in the `.rgf` file (`quoted` in the above example).
*   The name of the class derived from `feature_function` that has a method `extract` which actually computes the feature (`fquoted` in the above example).
