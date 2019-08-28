# Tokenizer Module {#tokenizer-module}

The first module in the processing chain is the tokenizer. It converts plain text to a vector of <tt>word</tt> objects, according to a set of tokenization rules.

Tokenization rules are regular expressions that are matched against the beggining of the text line being processed. The first matching rule found is used to extract the token, the matching substring is deleted from the line, and the process is repeated until the line is empty.

The API of the tokenizer module is the following:

```C++
class tokenizer {
  public:
    /// Constructor
    tokenizer(const std::wstring &cfgfile);

    /// tokenize string, leave result in lw
    void tokenize(const std::wstring &text, 
                  std::list<word> &lw) const;

   /// tokenize string, return result as list
    std::list<word> tokenize(const std::wstring &text) const;

    /// tokenize string, updating byte offset. Leave results in lw.
    void tokenize(const std::wstring &text, 
                  unsigned long &offset, 
                  std::list<word> &lw) const;

    /// tokenize string, updating offset, return result as list
    std::list<word> tokenize(const std::wstring &text, 
                             unsigned long &offset) const;
};
```

That is, once created, the tokenizer module receives plain text in a string, tokenizes it, and returns a list of <tt>word</tt> objects corresponding to the created tokens

## Tokenizer Rules File {#tokenizer-rules-file}

The tokenizer rules file is divided in three sections `<Macros>`, `<RegExps>` and `<Abbreviations>`. Each section is closed by `</Macros>`, `</RegExps>` and `</Abbreviations>` tags respectively.

The `<Macros>` section allows the user to define regexp macros that will be used later in the rules. Macros are defined with a name and a POSIX regexp. E.g.:  
`MYALPHA [A-Za-z]`  
`ALPHA [[:alpha:]]`

The `<RegExps>` section defines the tokenization rules. Previously defined macros may be referred to with their name in curly brackets. E.g.:  
`*ABREVIATIONS1 0 ((\{ALPHA\}+\.)+)(?!\.\.)`

Rules are regular expressions, and are applied in the order of definition. The first rule matching the beginning of the line is applied, a token is built, and the rest of the rules are ignored. The process is repeated until the line has been completely processed.

The format of each rule is:

*   The first field in the rule is the rule name. If it starts with a <tt>*</tt>, the RegExp will only produce a token if the match is found in the abbreviation list (`<Abbreviations>` section). Apart from that, the rule name is only for informative/readability purposes.
*   The second field in the rule is the substring to form the token/s with. It may be 0 (the match of the whole expression) or any number from 1 to the number of subexpression (up to 9). A token will be created for each subexpression from 1 to the specified value.
*   The third field is the regexp to match against the input. line. Any POSIX regexp convention may be used.
*   An optional fourth field may be added, containing the string <tt>CI</tt> (standing for Case Insensitive). In this case, the input text will be matched case-insensitively against the regexp. If the fourth field is not present, or it is different than <tt>CI</tt>, the rule is matched case-sensitively.

The `<Abbreviations>` section defines common abbreviations (one per line) that must not be separated of their following dot (e.g. <tt>etc.</tt>, <tt>mrs.</tt>). They must be lowercased, even if they are expected to appear uppercased in the text.
