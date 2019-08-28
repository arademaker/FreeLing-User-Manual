
# Dictionary Search Module {#dictionary-search-module}

The dictionary search module has two functions: Search the word forms in the dictionary to find out their lemmas and PoS tags, and apply affixation or compounding rules to find the same information in the cases in which the form is a derived form not included in the dictionary (e.g. the word *quickly* may not be in the dictionary, but a suffixation rule may state that removing suffix *-ly* and searching for the obtained adjective is a valid way to form and adverb).

The decision of what is included in the dictionary and what is dealt with through affixation rules is left to the linguist building the linguistic data resources.

The API for this module is the following:   
```C++
class dictionary {
  public:
    /// Constructor
    dictionary(const std::wstring &Lang, const std::wstring &dicFile, 
               const std::wstring &sufFile, const std::wstring &compFile,
               bool invDic=false, bool retok=true);

    /// Destructor
    ~dictionary();

    /// add analysis to dictionary entry (create entry if not there)
    void add_analysis(const std::wstring &form, const analysis &an);

    /// remove entry from dictionary
    void remove_entry(const std::wstring &form);

    /// customize behaviour of dictionary for further analysis
    void set_retokenize_contractions(bool b); 
    void set_affix_analysis(bool b);
    void set_compound_analysis(bool b);

    /// find out whether the dictionary has loaded an affix or compounds module
    bool has_affixes() const;
    bool has_compounds() const;

    /// Get dictionary entry for a given form, add to given list.
    void search_form(const std::wstring &form, std::list<analysis> &la) const;

    /// Fills the analysis list of a word, checking for suffixes and contractions.
    /// Returns true iff the form is a contraction, returns contraction components
    /// in given list
    bool annotate_word(word &w, std::list<word> &lw, bool override=false) const;

    /// Fills the analysis list of a word, checking for suffixes and contractions.
    /// Never retokenizing contractions, nor returning component list.
    /// It is just a convenience equivalent to "annotate_word(w,dummy,true)"
    void annotate_word(word &w) const;

    /// Get possible forms for a lemma+pos (requires inverseDict=true
    /// when module was instantiated)
    std::list<std::wstring> get_forms(const std::wstring &lemma, 
                                      const std::wstring &pos) const;

    /// analyze given sentence.
    void analyze(sentence &s) const;

    /// analyze given sentences.
    void analyze(std::list<sentence> &ls) const;

    /// return analyzed copy of given sentence
    sentence analyze(const sentence &ls) const;

    /// return analyzed copy of given sentences
    std::list<sentence> analyze(const std::list<sentence> &ls) const;
};
```

The parameters of the constructor are:

*   The language of the processed text. This is required by the affixation submodule to properly handle graphical accent rules in latin languages.
*   The dictionary file name. See below for details.
*   The affixation rules file name (an empty string means no affix analysis is to be performed). 
*   The compound rules file name (an empty string means no compound analysis is to be performed). 
*   An optional boolean (default: false) stating whether the dictionary must be created with inverse access, to enable the use of `get_forms` to obtain a word form given a lemma+PoS pair.
*   An optional boolean (default: true) stating whether the contractions found in the dictionary must be retokenized right away, or left for later modules to decide.

The dictionary content may be updated online using the methods `add_analysis` and `remove_entry`. Notice that this will modify the dictionary instance in RAM, but not the file in the disk. If you want your changes to be permanent, modify the dictionary file instead.

The dictionary module behaviour may be tuned on-the-fly with the methods `set_affix_analysis`, `set_retokenize_contractions`, and `set_compound_analysis`, which will activate (when parameter is <tt>true</tt>) or deactivate (when <tt>false</tt>) the specified feature for any further call to the `analyze` methods.

## Form Dictionary File {#form-dictionary-file}

The form dictionary contais two required sections: `<IndexType>` and `<Entries>`

Section `<IndexType>` contains a single line, that may be either `DB_PREFTREE` or `DB_MAP`. With `DB_MAP` the dictionary is stored in a C++ STL <tt>map</tt> container. With `DB_PREFTREE` it is stored in a prefix-tree structure. Depending on the size of the dictionary and on the morphological variation of the language, one structure may yield slightly better access times than the other.

Section `<Entries>` contains lines with one form per line. Each form line has format: <tt>form lemma1 PoS1 lemma2 PoS2 ...</tt>. E.g.:

```
casa casa NCFS000 casar VMIP3S0 casar VMM02S0
backs back NNS back VBZ
```

Lines corresponding to words that are contractions may have an alternative format if the contraction is to be splitted. The format is <tt>form form1+form2+... PoS1+PoS2+...</tt> where <tt>form1,form2,...</tt> are the forms (not the lemmas) of the contracted words. For instance:  
`del de+el SP+DA`

This line expresses that whenever the form *del* is found, it is replaced with two words: *de* and *el*. Each of the new two word forms are searched in the dictionary, and assigned any tag matching their correspondig tag in the third field. So, *de* will be assigned all tags starting with <tt>SP</tt> that this entry may have in the dictionary, and *el* will get any tag starting with <tt>DA</tt>.

Note that a contraction included in the dictionary cannot be splitted in two different ways corresponding to different forms (e.g. <tt>he's = he+is | he+has</tt>), so only a combination of forms and a combination of tags may appear in the dictionary.
That is, the dictionary entry:  
`he's he+is PRP+VB he+has PRP+VB`  
is invalid because it states two different forms for *'s*, while the entry:  
`he's he+'s PRP+VB`  
is valid because it only states a form (*'s*) that will get two lemmas (*be* and *have*) when looked up in the dictionary.

Also, a set of tags may be specified for a given form, e.g.:  
`he'd he+'d PRP+VB/MD`

This will produce two words: *he* with <tt>PRP</tt> analysis, and *'d* with its analysis matching any of the two given tags (i.e. <tt>have_VBZ</tt> and <tt>would_MD</tt>). Note that this will work only if the form 'd is found in the dictionary with those possible analysis.

If all tags for one of the new forms are to be used, a wildcard may be written as a tag. e.g.: `pal para+el SP+*`

This will replace pal with two words, para with only its <tt>SP</tt> analysis, plus el with all its possible tags.

The contraction entries in the dictionary are intended for inambiguous contractions, or for cases such that it is not worth (or it is too difficult) to handle otherwise. For splitting more sophisticated compound words, such as verb clitic pronouns in Spanish or Italian (e.g dale → dar+él), derivation (e.g. _quick → quickly_, rápida → rápidamente), diminutive/augmentative sufixes, prefixes, or other similar behaviours, the affixation module should be used.

An optional parameter in the constructor enables to control whether contractions are splitted by the dictionary module itself (thus passing two words instead of one to later modules) or the decision is left to later modules (which will receive a single word carrying retokenization information).

## Affixation Rules File {#affixation-rules-file}

The submodule of the dictionary handler that deals with affixes requires a set of affixation rules.

The file consists of two (optional) sections: `<Suffixes>` and `<Prefixes>`. The first one contains suffixation rules, and the second, prefixation rules. They may appear in any order.

Both kinds of rules have the same format, and only differ in whether the affix is checked at the beggining or at the end of the word.

Each rule has to be written in a different line, and has 10 fields:

1.  Affix to erase form word form (e.g: _crucecita - cecita = cru_)
2.  Affix (`*` for emtpy string) to add to the resulting root to rebuild the lemma that must be searched in dictionary (e.g. _cru + z = cruz_)
3.  Condition on the tag of found dictionary entry (e.g. _cruz_ has tag <tt>NCFS</tt> in the dictionary). The condition is a perl RegExp
4.  Tag for suffixed word (`*` = keep tag in dictionary entry)
5.  Check lemma adding accents
6.  Enclitic suffix (special accent behaviour in Spanish)
7.  Prevent later modules (e.g. probabilities) from assigning additional tags to the word
8.  Lemma to assign: Any combination of: <tt>F</tt>, <tt>R</tt>, <tt>L</tt>, <tt>A</tt>, or a string literal separated with a <tt>+</tt> sign. For instance: <tt>R+A</tt>, <tt>A+L</tt>, <tt>R+mente</tt>, etc.

    <tt>F</tt> stands for the original form (before affix removal, e.g. _crucecitas_), <tt>R</tt> stands for root found in dictionary (after affix removal and root reconstruction, e.g. _cruces_), <tt>L</tt> stands for lemma in matching dictionary entry (e.g. _cruz_), <tt>A</tt> stands for the affix that the rule removed

9.  Try the affix always, not only for unknown words.
10.  Retokenization info, explained below ("`-`" for none)

Example of prefix rule:  
`anti * ^NC AQ0CN0 0 0 1 A+L 0 -`

This prefix rule states that <tt>anti</tt> should be removed from the beggining of the word, nothing (`*`) should be added, and the resulting root should be found in the dictionary with a <tt>NC</tt> PoS tag. If that is satisfied, the word will receive the <tt>AQ0CN0</tt> tag and its lemma will be set to the affix (<tt>anti</tt>) plus the lemma of the root found in the dictionary. For instance, the word <tt>antimisiles</tt> would match this rule: <tt>misiles</tt> would be found in the dictionary with lema <tt>misil</tt> and PoS <tt>NCMP000</tt>. Then, the word will be assigned the lemma <tt>antimisil</tt> (<tt>A+L = anti+misil</tt>) and the tag <tt>AQ0CN0</tt>.

Examples of sufix rules:
```
cecita z|za ^NCFS NCFS00A 0 0 1 L 0 -
les * ^V * 0 1 0 L 1 $$+les:$$+PP
```

The first suffix rule above (<tt>cecita</tt>) states a suffix rule that will be applied to unknown words, to see whether a valid feminine singular noun is obtained when substituting the suffix <tt>cecita</tt> with <tt>z</tt> or <tt>za</tt>. This is the case of <tt>crucecita</tt> (diminutive of <tt>cruz</tt>). If such a base form is found, the original word is analyzed as diminutive suffixed form. No retokenization is performed.

The second rule (<tt>les</tt>) applies to all words and tries to check whether a valid verb form is obtained when removing the suffix <tt>les</tt>. This is the case of words such as <tt>viles</tt> (which may mean I saw them, but also is the plural of the adjective <tt>vil</tt>).

In this case, the retokenization info states that if eventually the verb tag is selected for this word, it may be retokenized in two words: The base verb form (referred to as <tt>\$\$</tt>, <tt>vi</tt> in the example) plus the word <tt>les</tt>. The tags for these new words are expressed after the colon: The base form must keep its PoS tag (this is what the second <tt>\$\$</tt> means) and the second word may take any tag starting with PP the word may have in the dictionary. Prefixing a tag in the retokenization information with a `!` sign will assign that tag without performing any dictionary check. (E.g. if the rule was <tt>\$\$+les:\$\$+!XYZ</tt>, the word <tt>les</tt> would get the tag <tt>XYZ</tt> regardless of whether either the word or the tag are found in the dictionary.

So, for word <tt>viles</tt>, we would obtain its adjective analysis from the dictionary, plus its verb + clitic pronoun from the suffix rule: `viles vil AQ0CP0 ver+les VMIS1S0+PP3CD00`

The second analysis will carry the retokenization information, so if eventually the PoS tagger selects the <tt>VMI</tt> analysis (and the TaggerRetokenize option is set), the word will be retokenized into:

```
vi ver VMIS1S0
les ellos PP3CPD00
```

## Compound rules file {#compound-rules-file}

The dictionary may be configured to check whether a word is a compound formed by the concatenation of several dictionary words.

The compounds will be detected if they are formed strictly by words in the dictionary, either glued toghether (e.g. _ghostbusters_, _underworld_), or separated with a character especified to be a compound joint (e.g. a dash: _middle-aged_, self-sustained_). In the current version, if a component of the compound is a form derived via affixation (e.g. _extremely-complex_) it will not be detected, even if the base form for the affixed word (_extreme_ in this case) is in the dictionary.

The submodule of the dictionary handler that deals with compounds requires a set of valid compound patterns. The configuration file for the compound detection module consists of three sections: `<UnknownWordsOnly>`, `<JoinChars>`, and `<CompoundPatterns>`.

Section `<UnknownWordsOnly>` is optional, and contains just one line with either `yes` or `no`. Default is `yes`, meaning that only words not found in the dictionary or solved by the affixation module will be tried as potential compounds. If the option is set to `no`, all words will be tried as potential compounds (probably overgenerating wrong analysis).

Section `<JoinChars>` contains a list of characters to be considered compound joints. A typical member of this list is the dash ``-'', though the list may vary from one language to another. The character list must be specified with one character per line.

Section `<CompoundPatterns>` contains a list of valid compound patterns. Each pattern must be defined in a separate line.

There are two possible formats for specifying a pattern:

*   `headed_PoS_pattern` This pattern consists of a sequence of PoS tag prefixes separated by underscores. Exactly one of the tags must be preceeded with a plus sign (`+`) that indicates it is the head of the compound, and thus its PoS tag will be used as the tag of the compound.

    For instance, the pattern `JJ_+NN` will recognize compounds such as _lightweight_ or _lightweights_, since their components match the categories in the pattern. The compound will receive the PoS tag of the second component, producing the analyses <tt>(light_weight,NN)</tt> and <tt>(light_weight,NNS)</tt> respectively.

*   `PoS_pattern compound_PoS` Patterns specified in this way behave like described above, but no head marker is expected in the `PoS_pattern`. Instead of using the head PoS, the PoS tag for the compound is straightforwardly set to the value of `compound_PoS`.

For flexibility, in any of both rule formats, a wildcard `*` may be used instead of a PoS prefix, causing that part of the pattern to match any PoS tag.

## Dictionary Management {#dictionary-management}

In many NLP applications you want to deal with text in a particular domain, which contain words or expressions (terminology, proper nouns, etc.) that are specific or have a particular meaning in that domain.

Thus, you may want to extend you dictionary to include such words. There are two main ways of doing this:

*   Extend your dictionary: Dictionaries are created at installation time from sources in the directory `data/XX/dictionary` (where `XX` is the language code). Those files contain one triplet `word lemma tag` per line, and are fused in a single dictionary at installation time.

    The script in `src/utilities/dicc-management/bin/build-dict.sh` will read the given files and build a dictionary with all them (check the file `src/utilities/dicc-management/README` for details).

    Thus, if you have a domain dictionary with a list of triplets `word lemma tag`, you can build a new dictionary fusing the original FreeLing entries with your domain entries. The resulting file can be given to the constructor of the dictionary class.

*   Instantiate more than one dictionary module: Another option is to instatiate several dictionary modules (creating each one with a different dictionary file), and run the text through each of them sequentially. When the word is found in one dictionary along the chain, the following dictionary modules will ignore it and will not attempt to look it up.
