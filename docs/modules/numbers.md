# Number Detection Module {#number-detection-module}

The number detection module is language dependent: It recognizes nummerical expression (e.g.: <tt>1,220.54</tt> or <tt>two-hundred sixty-five</tt>), and assigns them a normalized value as lemma.

The module is basically an Augmented Transition Network (ATN) that recognizes valid nummerical expressions. Since the structure of the automata and the actions to compute the actual nummerical value are different for each lemma, the ATN is coded in C++ and has to be rewritten for any new language.

For languages that do not have an implementation of a specific automata, a generic module is used to recognize number-like expressions that contain nummerical digits.

There is no configuration file to be provided to the class when it is instantiated.

The API of the class is:

```C++  
class numbers {
  public:
    /// Constructor: receives the language code, and the decimal 
    /// and thousand point symbols
    numbers(const std::string &lang, 
            const std::string &dec, 
            const std::string &thou); 

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

Parameters expected by the constructor are:

*   The language code: used to decide whether the generic recognizer or a language-specific module is used.
*   The decimal point symbol.
*   The thousand point sympol.

The last two parameters are needed because in some latin languages, the comma is used as decimal point separator, and the dot as thousand mark, while in languages like English it is the other way round. These parameters make it possible to specify what character is to be expected at each of these positions. They will usually be comma and dot, but any character could be used.
