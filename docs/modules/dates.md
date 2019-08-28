# Dates Detection Module {#dates-detection-module}

The dates detection module, as the number detection module, is a collection of language-specific Augmented Transition Networks, and for this reason needs no data file to be provided at instantiation time.

For languages that do not have a specific ATN, a default analyzer is used that detects simple date patterns (e.g. <tt>DD-MM-AAAA</tt>, <tt>MM/DD/AAAA</tt>, etc.)

The API of the class is:

```C++        
class dates {             
  public:   
    /// Constructor: receives the language code
    dates(const std::string &lang); 

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

The only parameter expected by the constructor is the language of the text to analyze, in order to be able to apply the appropriate specific automata, or select the default one if none is available.

The dates module will create a multiword for the whole date expression, and set a lemma for the multiword that normalizes the fields of the date/time expression. Fields not specified in the expression are set to `??`.
E.g.:  
* The expression _thursday, may 15th, two thousand and six_ will generate the multiword `thursday_,_may_15th_,_two_thousand_and_six`, and set its lemma to `[J:15/5/2002:??.??:??]`
* The expression _may 15th at ten past four in the afternoon_ will generate the multiword `may_15th_at_ten_past_four_in_the_afternoon`, and set its lemma to `[??:15/5/??:4.10:pm]`


The lemma has the format `[w:DD/MM/YYYY:hh.mm:tt]`, where:
* `w`: Weekday code (`L`: Monday, `M`: Tuesday, `X`: Wednesday, `J`: Thursday, `V`: Friday, `S`: Saturday, `D`: Sunday)
* `DD`: day number
* `MM`: month number
* `YYYY`: year number
* `hh`: hour
* `mm`: minute
* `tt`: `am` or `pm` 