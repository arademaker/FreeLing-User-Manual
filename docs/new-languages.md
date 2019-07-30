# Adding Support for New Languages {#new-languages}

It is possible to extend the library with capability to deal with a new language.

In many cases, this may be done simply providing the appropriate linguistic data, with no need to modify any code. Some modules, however, do require entering into the code.

Since the text input language is an configuration option of the system, a new configuration file must be created for the language to be added (e.g. copying and modifying an existing one.  The new configuration file must point to the new configuration or data files for each module.

Details on the format for configuration files for each individual module can be found in chapter about [Language Processing Modules](processing-classes.md).

## Tokenizer

The first module in the processing chain is the tokenizer. 
The behaviour of the tokenizer is controlled via the TokenizerFile option in configuration file.

To create a tokenizer for a new language, just create a new tokenization rules file (e.g. copying an existing one and adapting its regexps to particularities of your language), and set it as the value for the TokenizerFile option in your new configuration file.

## Morphological analyzer

The morphological analyzer module consists of several sub-modules:

### Multiword detection {#multiword-detection}

Just create a multiword file in the appropriate format.
The LocutionsFile option in configuration file must be set to the name of a file that contains the multiwords you want to detect in your language.

### Nummerical expression detection {#nummerical-expression-detection}

If no specialized module is defined to detect nummerical expressions, the default behaviour is to recognize only numbers and codes written in digits (or mixing digits and non-digit characters).

If you want to recognize language dependent expressions (such as numbers expressed in words -e.g. ``one hundred thirthy-six''), you have to program a `numbers_mylanguage` class derived from abstract class `numbers_module`. Those classes are finite automata that recognize word sequences. An abstract class `automat` controls the sequence advance, so your derived class has little work to do apart from defining states and transitions for the automaton.

A good idea to start with this issue is having a look at the `numbers_es`, `numbers_en`, `and numbers_ca` classes.
 State/transition diagrams of those automata can be found in the directory `doc/diagrams`.

### Date/time expression detection {#date-time-expression-detection}

If no specialized module is defined to detect date/time expressions, the default behaviour is to recognize only simple date expressions (such as DD/MM/YYYY).

If you want to recognize language dependent expressions (such as complex time expressions -e.g. ``wednesday, July 12th at half past nine''), you have to program a `date_mylanguage` class derived from abstract class `dates_module`. Those classes are Augmented Transition Netwrots that recognize word sequences. An abstract class `automat` controls the sequence advance, so your derived class has little work to do apart from defining states and transitions for the automaton.

A good idea to start with this issue is having a look at the `dates_es`, `dates_en`, and `dates_ca` classes. State/transition diagrams of those automata can be found in the directory `doc/diagrams`.

### Currency/ratio expression detection {#currency-ratio-expression-detection}

If no specialized module is defined to detect date/time expressions, the default behaviour is to recognize only simple percentage expressions (such as ``23%'').

If you want to recognize language dependent expressions (such as complex ratio expressions -e.g. ``three out of four''- or currency expression -e.g. ``2,000 australian dollar''), you have to program a `quantities_mylanguage` class derived from abstract class `quantities_module`. Those classes are Agumented Transition Networks that recognize word sequences. An abstract class `automat` controls the sequence advance, so your derived class has little work to do apart from defining states and transitions for the automaton.

A good idea to start with this issue is having a look at the `quantities_en` and `quantities_es` classes.

In the case your language is a roman language (or at least, has a similar structure for currency expressions) you can easily develop your currency expression detector by copying the `quantities_es` class, and modifying the QuantitiesFile option to provide a file in which lexical items are adapted to your language. For instance: Catalan currency recognizer uses a copy of the `quantities_es` class, but a different QuantitiesFile, since the syntactical structure for currency expression is the same in both languages, but lexical forms are different.

If your language has a very different structure for those expressions, you may require a different format for the QuantitiesFile contents. Since that file will be used only for your language, feel free to readjust its format.

### Dictionary search {#dictionary-search}

The lexical forms for each language are sought in a database. You only have to specify in which file it is found with the DictionaryFile option.

The dictionary file can be build with the `src/utilities/dicc-management/build-dict.sh` script included in FreeLing tarball. 
This program reads all dictionary entry lists given as parameter, and builds a unique file containg a dictionary suitable for FreeLing.

The input files are expected to contain one word form per line, each line with the format: <tt>form lemma1 tag</tt>   
E.g.:  
```
abalanzará abalanzar VMIC1S0
abalanzará abalanzar VMIC3S0
bajo bajar VMIP1S0
bajo bajo AQ0MS0
...
```

### Affixed forms search {#affixed-forms-search}

Forms not found in dictionary may be submitted to an affix analysis to devise whether they are derived forms. The valid affixes and their application contexts are defined in the affix rule file referred by AffixFile configuration option. 

If your language has ortographic accentuation (such as Spanish, Catalan, and many other roman languages), the suffixation rules may have to deal with accent restoration when rebuilding the original roots. To do this, you have to program a `accents_mylanguage` class derived from abstract class `accents_module`, which provides the service of restoring (according to the accentuation rules in your languages) accentuation in a root obtained after removing a given suffix.

A good idea to start with this issue is having a look at the `accents_es` class.

### Probability assignment {#probability-assignment}

The module in charge of assigning lexical probabilities to each word analysis only requires a data file, referenced by the ProbabilityFile configuration option.

This file may be created using the script `src/utilities/train-tagger/bin/TRAIN.sh` included in FreeLing source package, and a tagged corpus.



## HMM PoS Tagger {#hmm-pos-tagger}

The HMM PoS tagger only requires an appropriate HMM parameters file, given by the TaggerHMMFile option. 

To build a HMM tagger for a new language, you will need corpus (preferably tagged), and you will have to write some probability estimation scripts (e.g. you may use MLE with a simple add-one smoothing).

Nevertheless, the easiest way (if you have a tagged corpus) is using the estimation and smoothing script `src/utilities/train-tagger/bin/TRAIN.sh` provided in FreeLing source package.

See file [`src/utilities/train-tagger/README`](https://github.com/TALP-UPC/FreeLing/blob/master/src/utilities/train-tagger/README) for details

## Relaxation Labelling PoS Tagger {#relaxation-labelling-pos-tagger}

The Relaxation Labelling PoS tagger only requires an appropriate pseudo- constraint grammar file, given by the RelaxTaggerFile option.

To build a Relax tagger for a new language, you will need corpus (preferably tagged), and you will have to write some compatibility estimation scripts. You can also write from scratch a knowledge-based constraint grammar.

Nevertheless, the easiest way (if you have a tagged corpus) is using the estimation and smoothing script `src/utilities/train-tagger/bin/TRAIN.sh` provided in FreeLing source package.

See file [`src/utilities/train-tagger/README`](https://github.com/TALP-UPC/FreeLing/blob/master/src/utilities/train-tagger/README) for details


## Named Entity Recognizer and Classifier {#named-entity-recognizer-and-classifier}

Named Entity recognition and classification modules can be trained for a new language, provided a hand-annotated large enough corpus is available.

See file [`src/utilities/train-nrec/README`](https://github.com/TALP-UPC/FreeLing/blob/master/src/utilities/train-nerc/README) for details.


## Chart Parser {#chart-parser}

The parser only requires a grammar which is consistent with the tagset
used in the morphological and tagging steps. The grammar file must be
specified in the GrammarFile option (or passed to the parser
constructor).

## Rule-based Dependency Parser {#dependency-parser}

The depencency parser only requires a set of rules which is consistent
with the PoS tagset and the non-terminal categories generated by the
Chart Parser grammar. The grammar file must be specified in the
DepRulesFile option (or passed to the parser constructor).

## Statistical Dependency Parser and SRL

The statistical depencency parser requires a training corpus with PoS
tags matching those produced by the tagger.  The corpus needs to be in
CoNLL format. 

Dependency relations are the output of the module, so they can be
any. Of course, later modules (SRL, coreference) will need to be
trained or configured to match the labels produced by the dependency
parser.

