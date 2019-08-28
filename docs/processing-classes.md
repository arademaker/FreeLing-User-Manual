# Language Processing Modules {#language-processing-modules}

This chapter describes each of the modules in FreeLing. For each module, its public API is described, as well as its main configuration options. Most modules can be customized via a configuration file.

A typical module receives a list of sentences, and enriches them with new linguistic information (morphological analysis, disambiguation, parsing, etc.)

Usually, when the module is instantiated, it receives as a parameter the name of a file where the data and/or parameters needed by the module are stored (e.g. a dictionary file for the dictionary search module, or a CFG grammar for a parser module).

Most modules are language-independent, that is, if the provided file contains data for another language, the same module will be able to process that language.

All modules are thread-safe (though some such as the sentence splitter need a session identifier token to ensure this safety).

If an application needs to process more than one language, it can instantiate the needed modules for each language simply calling the constructors with different data files as a parameter.

### Main processing classes in FreeLing

* [Language Identifier](modules/lang_ident.md)
* [Tokenizer](modules/tokenizer.md)
* [Sentence Splitter](modules/splitter.md)
* [Morphological Analyzer](modules/maco.md)
    * [Punctuation Detection](modules/punct.md)
    * [Number Detection](modules/numbers.md)
    * [User Map Module](modules/usermap.md)
    * [Dates Detection](modules/dates.md)
    * [Dictionary Search](modules/dictionary.md)
    * [Multiword Recognition](modules/locutions.md)
    * [Named Entity Recognition](modules/ner.md)
    * [Quantity Recognition](modules/quantities.md)
    * [Probability Assignment and Guesser](modules/probabilities.md)
* [Alternative Suggestion](modules/alternatives.md)
* [Sense Labelling](modules/senses.md)
* [Word Sense Disambiguation](modules/wsd.md)
* [Part-of-Speech Tagger](modules/tagger.md)
* [Phonetic Encoding](modules/phonetics.md)
* [Named Entity Classification](modules/nec.md)
* [Chart Parser](modules/chart_parser.md)
* [Rule-based Dependency Parser](modules/dep_txala.md)
* [Statistical Dependency Parser and SRL](modules/dep_treeler.md)
* [Coreference Resolution](modules/coreference.md)
* [Semantic Graph Extraction](modules/semgraph.md)

### Other Useful Modules  

  FreeLing contains some internal classes used by the analysis modules described above, as well as other utility classes (e.g. to handle input/output formats). Some applications may be interested in directly accessing these lower-level utilities, the most relevant of which are:
* [Analyzer Metamodule](modules/analyzer.md)
* [Tagset Management](modules/tagset.md)
* [Semantic Database](modules/semdb.md)
* [Approximate Search Dictionary](modules/foma.md)
* [Feature Extractor](modules/fex.md)
* [Input/Output Formats](modules/io.md)

