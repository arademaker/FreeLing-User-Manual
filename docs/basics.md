#Basic Concepts {#basic-concepts}

FreeLing is a C++ library providing language analysis services (such as morphological analysis, date recognition, PoS tagging, parsing, etc.)

The current version provides language identification, tokenizing, sentence splitting, morphological analysis, NE detection and classification, recognition of dates/numbers/physical magnitudes/currency/ratios, phonetic encoding, PoS tagging, shallow parsing, dependency parsing, WN-based sense annotation, Word Sense Disambiguation, Semantic Role Labelling, and coreference resolution. Future versions are expected to improve performance in existing functionalities, as well as incorporate new features.

FreeLing is designed to be used as an external library from any application requiring this kind of services. If the calling application is written in C++ native calls to the library can be performed. Alternatively, APIs are provided to call main FreeLing functionalities from programs in Java, Perl, or Python.

Additionally, a command-line main program with many customization options is also provided as a basic interface to the library, enabling the user to analyze text files with no need of coding any programs to call the library.

  ##What is FreeLing {#what-is-freeling}

FreeLing is a developer-oriented library providing language analysis services. If you want to develop, say, a machine translation system, and you need some kind of linguistic processing of the source text, your MT application can call FreeLing modules to do the required analysis.

In the directory `src/main/simple_examples` in FreeLing tarball, some sample programs are provided to illustrate how an application program can call the library.

In the directory `src/main/sample_analyzer` a couple of more complex programs are provided, which can be used either as a command line interface to the library to process texts, or as examples of how to build customized applications using FreeLing.

  1 ## What is NOT FreeLing {#what-is-not-freeling}

FreeLing is not a user-oriented text analysis tool. That is, it is not designed to be user friendly, to have a fancy GUI, or to output results with a cute image, or in a certain format.

FreeLing results are linguistic analysis in a data structure. Each end-user application (e.g. anything from a simple syntactic-tree drawing plugin to a complete machine translation system) can access those data and process them as needed.

Nevertheless, FreeLing package provides a quite complete application program `analyzer` that enables an end user with no programming skills to obtain the analysis of a text. See chapter about [<tt>analyzer</tt>](user-application.md) for details.

This program offers a set of options that cover most of FreeLing capabilities. Nevertheless, much more advantadge can be taken of FreeLing, and more information can be accessed if you call FreeLing from your own application program.

FreeLing library also includes some classes that are able to dump FreeLing data tructures into some common formats, such as XML or CoNLL-like column format. These classes are limited and may not be able to generate any desired output format as they are out-of-the box, but can be adjusted to your needs or used as a starting poit to write your own dumper to your preferred output format.

## Supported Languages {#supported-languages}

The current version supports the following languages(to different extents and accuracy levels, see table below): Asturian (as), Catalan (ca), German (de), English (en), French (fr), Galician (gl), Croatian (hr), Italian (it), Norwegian (nb), Portuguese (pt), Russian (ru), Slovene (sl), Spanish (es), and Welsh (cy).

**Table 1.1:** Analysis services available for each language.

|                             | as  | ca  | cy  | de  | en  | es  | fr  | gl  | hr  | it  | nb  | pt  | ru  | sl  |
|-----------------------------|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
|Tokenization                 | X   | X   | X   | X   | X   | X   | X   | X   | X   | X   | X   | X   | X   | X   |
|Sentence splitting           | X   | X   | X   | X   | X   | X   | X   | X   | X   | X   | X   | X   | X   | X   |
|Number detection             |     | X   |     | X   | X   | X   | X   | X   |     | X   |     | X   | X   |     |
|Date detection               |     | X   |     | X   | X   | X   | X   | X   |     |     |     | X   | X   |     |
|Morphological dictionary     | X   | X   | X   | X   | X   | X   | X   | X   |     | X   | X   | X   | X   | X   |
|Affix rules                  | X   | X   | X   | X   | X   | X   | X   | X   |     | X   | X   | X   |     |     |
|Multiword detection          | X   | X   | X   |     | X   | X   | X   | X   |     | X   |     | X   |     |     |
|Basic named entity detection | X   | X   | X   |     | X   | X   | X   | X   |     | X   |     | X   | X   | X   |
|B-I-O named entity detection |     | X   |     |     | X   | X   |     | X   |     |     |     | X   |     |     |
|Named Entity Classification  |     | X   |     |     | X   | X   |     |     |     |     |     | X   |     |     | 
|Quantity detection           |     | X   |     |     | X   | X   |     | X   |     |     |     | X   | X   |     | 
|PoS tagging                  | X   | X   | X   | X   | X   | X   | X   | X   |     | X   | X   | X   | X   | X   | 
|Phonetic encoding            |     |     |     |     | X   | X   |     |     |     |     |     |     |     |     | 
|WN sense annotation          |     | X   |     |     | X   | X   | X   | X   | X   |     |     |     |     | X   |
|UKB sense disambiguation     |     | X   |     |     | X   | X   | X   | X   | X   |     |     |     |     | X   |
|Shallow parsing              | X   | X   |     |     | X   | X   |     | X   |     |     |     | X   |     |     | 
|Full/dependency parsing      | X   | X   |     |     | X   | X   |     | X   | X   |     |     |     |     | X   |
|Semantic Role Labelling      |     | X   |     | X   | X   | X   |     |     |     |     |     |     |     |     |
|Coreference resolution       |     |     |     |     | X   | X   |     |     |     |     |     |     |     |     | 

FreeLing is designed to be modular and to keep linguistic data separated from code. So, most modules can be adapted to a new language just replacing a configuration file or providing a file with rules specific for that language.

Thus, most of the missing crosses in previous table could be filled up just writting a small configuration or rule file (this is the case of, e.g. affixation rules, multiword detection, basic named entity detection, quantity detection, phonetic encoding) or an appropriate dictionary/lexicon file (e.g. Morphological dictionary or WN sense annotation modules).

FreeLing also includes WordNet-based sense dictionaries for some of the covered languages, as well as some knowledge extracted from WordNet, such as semantic file codes, or hypernymy relationships. See [http://wordnet.princeton.edu](http://wordnet.princeton.edu) and [http://www.illc.uva.nl/EuroWordNet](http://www.illc.uva.nl/EuroWordNet) for details on WordNet and EuroWordNet, respectively.

See the [Linguistic Data](http://nlp.lsi.upc.edu/freeling/linguistic-data) section on FreeLing webpage to find out more about the size and origin the linguistic resources for these languages.

See file [<tt>COPYING</tt>](https://github.com/TALP-UPC/FreeLing/blob/master/COPYING) in the distribution packages to find out the license of each third-party linguistic resource included in FreeLing packages.

## License {#license}

FreeLing code is licensed under Affero GNU General Public License ([AGPL](http://www.gnu.org/licenses/agpl.html)).

The linguistic data collections are distributed under diverse licenses, depending on their original sources.

Find the details in the [<tt>COPYING</tt>](https://github.com/TALP-UPC/FreeLing/blob/master/COPYING) file in the tarball, or in the [License](http://nlp.lsi.upc.edu/freeling/node/6) section in [FreeLing webpage](http://nlp.lsi.upc.edu/freeling).

## Contributions {#contributions}

FreeLing is developed and maintained by people in [TALP Research Center](http://www.talp.upc.edu) at Universitat Politecnica de Catalunya.

Many people further contributed to by reporting problems, suggesting various improvements, submitting actual code or extending linguistic databases. A detailed list can be found in [Contributions](http://nlp.lsi.upc.edu/freeling/node/5) section at [FreeLing webpage](http://nlp.lsi.upc.edu/freeling).

