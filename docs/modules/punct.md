# Punctuation Detection Module {#punctuation-detection-module}

The punctuation detection module assigns Part-of-Speech tags to punctuation symbols. The API of the class is the following:

```C++  
class punts {
  public:
    /// Constructor: load punctuation symbols and tags from given file
    punts(const std::string &cfgfile); 

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

The constructor receives as parameter the name of a file containing the list of the PoS tags to be assigned to each punctuation symbol.

Note that this module will be applied afer the tokenizer, so, it will only annotate symbols that have been separated at the tokenization step. For instance, if you include the three suspensive dots (...) as a single punctuation symbol, it will have no effect unless the tokenizer has a rule that causes these substring to be tokenized in one piece.

## Punctuation Tags File {#punctuation-tags-file}

The format of the file listing the PoS for punctuation symbols is one punctuation symbol per line, each line with the format: <tt>punctuation-symbol lemma tag</tt>. E.g.:

```
! ! Fat
, , Fc
: : Fd
... ... Fs
```

One special line may be included defining the tag that will be assigned to any other punctuation symbol not found in the list. Any token containing no alphanumeric character is considered a punctuation symbol. This special line has the format: `<Other> tag`.  
E.g.:  
`<Other> Fz`
