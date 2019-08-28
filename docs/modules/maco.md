
# Morphological Analyzer Module {#morphological-analyzer-module}

The morphological analyzer is a meta-module which does not perform any processing of its own.

It is just a convenience module to simplify the instantiation and call to the submodules described in the next sections.

At instantiation time, it receives a `maco_options` object, containing information about which submodules have to be created and which files must be used to create them.

Any submodule loaded at instantiation time, may be deactivated/reactivated later using the method `maco::set_active_options` described above. Note that a submodule that was not loaded when creating a `maco` instance, can neither be loaded nor activated later.

A calling application may bypass this module and just call directly the submodules.

The Morphological Analyzer API is:

```C++ 
class maco {
  public:
    /// Constructor. Receives a set of options.
    maco(const maco_options &); 

    /// change active options for further analysis
    void set_active_options(bool umap, bool num, bool pun, bool dat,
                            bool dic, bool aff, bool comp, bool rtk,
                            bool mw, bool ner, bool qt, bool prb);

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

The `maco_options` class has the following API:

```C++
class maco_options {
  public:
    // Language analyzed
    std::wstring Lang;

    /// Morphological analyzer modules configuration/data files.
    std::wstring LocutionsFile, QuantitiesFile, AffixFile, 
      CompoundFile, DictionaryFile, ProbabilityFile, NPdataFile, 
      PunctuationFile, UserMapFile;

    /// module-specific parameters for number recognition
    std::wstring Decimal, Thousand;

    /// module-specific parameters for probabilities
    double ProbabilityThreshold;

    /// module-specific parameters for dictionary
    bool InverseDict,RetokContractions;

    /// constructor
    maco_options(const std::wstring &); 

    /// Option setting methods provided to ease perl interface generation. 
    /// Since option data members are public and can be accessed directly
    /// from C++, the following methods are not necessary, but may become
    /// convenient sometimes.
    void set_data_files(const std::wstring &usr,
                        const std::wstring &pun, const std::wstring &dic,
                        const std::wstring &aff, const std::wstring &comp,
                        const std::wstring &loc, const std::wstring &nps,
                        const std::wstring &qty, const std::wstring &prb);
    void set_nummerical_points(const std::wstring &dec, const std::wstring &tho);
    void set_threshold(double);
    void set_inverse_dict(bool);
    void set_retok_contractions(bool);
  };
```

To instantiate a Morphological Analyzer object, the calling application needs to create an instance of `maco_options`, initialize its fields with the desired values, and use it to call the constructor of the `maco` class.

Each possible submodule will be created and loaded if the given file is different than the empty string. The created object will create the required submodules, and when asked to <tt>analyze</tt> some sentences, it will just pass it down to each submodule, and return the final result.

Class `maco_options` has convenience methods to set the values of the options, but note that all the members are public, so the user application can set those values directly if preferred.

Submodules called by the `maco` class are the following. 
Note that any of them can be instantiated and used directly if needed.

* [Punctuation Detection](modules/punct.md)
* [Number Detection](modules/numbers.md)
* [User Map Module](modules/usermap.md)
* [Dates Detection](modules/dates.md)
* [Dictionary Search](modules/dictionary.md)
* [Multiword Recognition](modules/locutions.md)
* [Named Entity Recognition](modules/ner.md)
* [Quantity Recognition](modules/quantities.md)
* [Probability Assignment and Guesser](modules/probabilities.md)
