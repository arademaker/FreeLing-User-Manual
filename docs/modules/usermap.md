
# User Map Module {#user-map-module}

The user map module assigns Part-of-Speech tags to words matching a given regular expression. It can be used to customize the behaviour of the analysis chain to specific applications, or to process domain-specific special tokens.

If used, it should be run before the other modules (e.g. morphological analysis) to prevent them from guessing possible PoS tags for special tokens.

The API of the class is the following:

```C++  
class RE_map {
  public:
    /// Constructor, load special token patterns
    RE_map(const std::wstring &cfgfile); 

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

The constructor receives as parameter the name of a file containing a list of regular expressions, and the list of pairs lemma-PoS tag to be assigned to each word matching the expression.

Note that this module will be applied afer the tokenizer, so, it will only annotate symbols that have been separated at the tokenization step. So, customizing your application to recognize certain special tokens may require modifying also the tokenizer configuration file.

Note also that if you introduce in this file PoS-tags which are not in the tagset known to the tagger, it may not be able to properly disambiguate the tag sequence.

Finally, note that this module sequentially checks each regular expression in the list against each word in the text. Thus, it should be used for patterns (not for fixed strings, which can be included in a dictionary file), and with moderation: using a very long list of expressions may severely slow down your analysis chain.

## User Map File {#user-map-file}

The format of the file containing the user map from regular expression to pairs lemma-PoS is one regular expression per line, each line with the format: <tt>regex lemma1 tag1 lemma2 tag2 ...</tt>.

The lemma may be any string literal, or <tt>\$\$</tt> meaning that the string matching the regular expression is to be used as a lemma. E.g.:  
```  
@[a-z][0-9] $ NP00000
<.*> XMLTAG Fz
hulabee hulaboo JJS hulaboo NNS
```

The first rule will recognize tokens such as `@john` or `@peter4`, and assign them the tag `NP00000` (proper noun) and the matching string as lemma.

The second rule will recognize tokens starting with `<` and ending with `>` (such as `<HTML>` or `<br/>`) and assign them the literal `XMLTAG` as lemma and the tag `Fz` (punctuation:others) as PoS.

The third rule will assign the two pairs lemma-tag to each occurrence of the word *hulabee*. This is just an example, and if you want to add a word to your dictionary, the dictionary module is the right place to do so.

Examples of possible configuration files for this module can be found in FreeLing data directory:
* `ca/twitter/usermap.dat`
* `es/twitter/usermap.dat`
* `en/twitter/usermap.dat`

