# Sense Labelling Module {#sense-labelling-module}

This module searches the lemma of each analysis in a sense dictionary, and enriches the analysis with the list of senses found there.

Note that this is not disambiguation, all senses for the lemma are returned.

The module receives a file containing several configuration options, which specify the sense dictionary to be used, and some mapping rules that can be used to adapt FreeLing PoS tags to those used in the sense dictionary.

FreeLing provides WordNet-based [\[Fel98,Vos98\]](../references.md) dictionaries, but the results of this module can be changed to any other sense catalogue simply providing a different sense dictionary file.

```C++
class senses {
  public:
    /// Constructor: receives the name of the configuration file
    senses(const std::string &cfgfile); 

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

The constructor of this class receives the name of a configuration file which is expected to contain the following sections:

*   A section `<WNposMap>` with the mapping rules of FreeLing PoS tags to sense dictionary PoS tags.  
    The format of the mapping rules is described in section [Semantic Database](semdb.md).

*   A section `<DataFiles>` containing the following pairs `keyword value`:

    * `SenseDictFile filename`  
       Sense dictionary to use. E.g.
       ```XML
       <DataFiles>
       SenseDictFile  ./senses30.src
       </DataFiles>
       ```
      The format of the sense dictionary is described in section [Semantic Database](semdb.md).

    * `formDictFile filename`  
       Form dictionary to use if mapping rules in `WNposMap` require the use of a form dictionary.


*   A section `<DuplicateAnalysis>` containing a single line with either `yes` or `no`, stating whether the analysis with more than one senses must be duplicated. If this section is ommitted, `no` is used as default value. The effect of activating this option is described in the following example:

    For instance, the word crane has the follwing analysis:
    ```
    crane NN  0.833
    crane VB  0.083
    crane VBP 0.083
    ```
    If the list of senses is simply added to each of them (that is, `DuplicateAnalysis` is set to `false`), you will get:
    ```
    crane NN  0.833  02516101:01524724
    crane VB  0.083  00019686
    crane VBP 0.083  00019686
    ```
    But if you set `DuplicateAnalysis` to true, the <tt>NN</tt> analysis will be duplicated for each of its possible senses:
    ```
    crane NN  0.416  02516101
    crane NN  0.416  01524724
    crane VB  0.083  00019686
    crane VBP 0.083  00019686
    ```
