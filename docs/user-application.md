# Using the library from your own application {#using-the-library-from-your-own-application}

The library may be used to develop your own NLP application (e.g. a machine translation system, an intelligent indexation module for a search engine, etc.)

To achieve this goal you have to link your application to the library, and access it via the provided API. 
Since the library is C++, using C++ in your program provides full access to all library functionalities.
However, quite complete APIs are provided for Java, Perl, Python, PHP, and Ruby.

## Basic Classes {#basic-classes}

This section briefs the basic C++ classes any application needs to know. 
For detailed API definition, consult the technical documentation in <tt>doc/html</tt> and <tt>doc/latex</tt> directories, or chapters about [Linguistic Data Classes](language-classes.md) or [Language Processing Modules](processing-classes.md)

### Linguistic Data Classes

The different processing modules work on objects containing linguistic data (such as a word, a PoS tag, a sentence...).

Your application must be aware of those classes in order to be able to provide to each processing module the right data, and to correctly interpret the module results.

The linguistic classes are:

*   <tt>analysis</tt>: A tuple `<lemma, PoS tag, probability, sense list>`
*   <tt>word</tt>: A word form with a list of possible analysis.
*   <tt>sentence</tt>: A list of words known to be a complete sentence. A sentence may have associated a <tt>parse_tree</tt> object and a <tt>dependency_tree</tt>.
*   <tt>parse_tree</tt>: An n-ary tree where each node contains either a non-terminal label, or -if the node is a leaf- a pointer to the appropriate <tt>word</tt> object in the sentence the tree belongs to.
*   <tt>dep_tree</tt>: An n-ary tree where each node contains a reference to a node in a <tt>parse_tree</tt>. The structure of the <tt>dep_tree</tt> establishes syntactic dependency relationships between sentence constituents.
*   <tt>paragraph</tt>: A list of <tt>sentence</tt> objects that form a paragraph.
*   <tt>document</tt>: A list of <tt>paragraph</tt> objects that form the document. A document may have associated a set of coreference groups and a semantic graph. 
*   <tt>mention</tt>: A mention of an entity in the document. A group of mentions referring to the same entity form a coreference group.
*   <tt>semantic_graph</tt>: An entity-relationship graph describing the main actions reported in the text and the principal actors involved in each.


### Processing modules

The main processing classes in the library are:

*   <tt>tokenizer</tt>: Receives plain text and returns a list of <tt>word</tt> objects.
*   <tt>splitter</tt>: Receives a list of <tt>word</tt> objects and returns a list of <tt>sentence</tt> objects.
*   <tt>maco</tt>: Receives a list of <tt>sentence</tt> objects and morphologically annotates each <tt>word</tt> object in the given sentences. Includes specific submodules (e.g, detection of date, number, multiwords, etc.) which can be activated at will.
*   <tt>tagger</tt>: Receives a list of <tt>sentence</tt> objects and disambiguates the PoS of each <tt>word</tt> object in the given sentences.
*   <tt>nec</tt>: Receives a list of <tt>sentence</tt> objects and modifies the tag for detected proper nouns to specify their class (e.g. person, place, organitzation, others).
*   <tt>ukb</tt>: Receives a list of <tt>sentence</tt> objects enriches the words with a ranked list of WordNet senses.
*   <tt>parser</tt>: Receives a list of <tt>sentence</tt> objects and associates to each of them a <tt>parse_tree</tt> object.
*   <tt>dependency</tt>: Receives a list of parsed <tt>sentence</tt> objects and associates to each of them a <tt>dep_tree</tt> object.
*   <tt>coref</tt>: Receives a document (containing a list of parsed <tt>sentence</tt> objects) and labels each noun phrase as belonging to a coreference group, if appropriate.

You may create as many instances of each as you need. Constructors for each of them receive the appropriate options (e.g. the name of a dictionary, hmm, or grammar file), so you can create each instance with the required capabilities (for instance, a tagger for English and another for Spanish).



## Sample programs {#sample-programs}

The directory `src/main/simple_examples` in the tarball contains some example programs to illustrate how to call the library.

See the README file in that directory for details on what does each of the programs.

The most complete program in that directory is <tt>sample.cc</tt>, which is a simple version of the <tt>analyzer</tt> program described in section [Using <tt>analyzer</tt> Program to Process Corpora](analyzer.md) with a fixed set of options.

Note that depending on the application, the input text could be obtained from a speech recongnition system, or from a XML parser, or from any source suiting the application goals. Similarly, the obtained analysis, instead of being output, could be used in a translation system, or sent to a dialogue control module, etc.

```C++
int main (int argc, char **argv) {
  /// set locale to an UTF8 comaptible locale
  util::init_locale(L"default");

  /// path where data files reside
  wstring path=L"/usr/local/share/freeling/es";
  
  // create analyzers
  tokenizer tk(path+L"tokenizer.dat"); 
  splitter sp(path+L"splitter.dat");
  splitter::session_id sid=sp.open_session();

  // morphological analysis has a lot of options, and for simplicity they are 
  // packed up in a maco_options object. 
  // First, create the maco_options object with default values.
  maco_options opt(L"es");  

  // then, provide files for morphological submodules. 
  // Note that opt.QuantitiesFile is not set and takes the default empty value.
  // This will cause quantities module to be deactivated in this example.
  opt.UserMapFile=L"";
  opt.LocutionsFile=path+L"locucions.dat"; opt.AffixFile=path+L"afixos.dat";
  opt.ProbabilityFile=path+L"probabilitats.dat"; opt.DictionaryFile=path+L"dicc.src";
  opt.NPdataFile=path+L"np.dat"; opt.PunctuationFile=path+L"../common/punct.dat"; 
  // alternatively, you could set the files in a single call:
  // opt.set_data_files("", path+"locucions.dat", "", path+"afixos.dat",
  //                   path+"probabilitats.dat", opt.DictionaryFile=path+"maco.db",
  //                   path+"np.dat", path+"../common/punct.dat");

  // create the analyzer with the just build set of maco_options
  maco morfo(opt); 
  // then, set required options on/off  
  morfo.set_active_options (false, // UserMap
                             true, // NumbersDetection,
                             true, //  PunctuationDetection,
                             true, //  DatesDetection,
                             true, //  DictionarySearch,
                             true, //  AffixAnalysis,
                             false, //  CompoundAnalysis,
                             true, //  RetokContractions,
                             true, //  MultiwordsDetection,
                             true, //  NERecognition,
                             false, //  QuantitiesDetection,
                             true); //  ProbabilityAssignment


  // create a hmm tagger for spanish (with retokenization ability, and forced 
  // to choose only one tag per word)
  hmm_tagger tagger(path+L"tagger.dat", true, FORCE_TAGGER); 
  // create chunker
  chart_parser parser(path+L"chunker/grammar-chunk.dat");
  // create dependency parser
  wstring S=parser.get_start_symbol();
  dep_txala dep(path+L"dep_txala/dependences.dat",S);
  
  // get plain text input lines while not EOF.
  wstring text;
  list<word> lw;
  list<sentence> ls;
  while (getline(wcin,text)) {

    // tokenize input line into a list of words
    lw=tk.tokenize(text);
    
    // accumulate list of words in splitter buffer, returning a list of sentences.
    // The resulting list of sentences may be empty if the splitter has still not 
    // enough evidence to decide that a complete sentence has been found. The list
    // may contain more than one sentence (since a single input line may consist 
    // of several complete sentences).
    ls=sp.split(sid, lw, false);
    
    // perform and output morphosyntactic analysis, Pos Tagging and parsing
    morfo.analyze(ls);
    tagger.analyze(ls);
    parser.analyze(ls);
    dep.analyze(ls);

    // 'ls' contains a list of analyzed sentences.  Do whatever is needed
    ProcessResults(ls);    
    // clear temporary lists;
    lw.clear(); ls.clear();    
  }

  // No more lines to read. Make sure the splitter doesn't retain anything  
  sp.split(sid, lw, true, ls);   
  sp.close_session(sid);
 
  // analyze sentence(s) which might be lingering in the buffer, if any.
  morfo.analyze(ls);
  tagger.analyze(ls);
  parser.analyze(ls);
  dep.analyze(ls);

  // 'ls' contains a list of analyzed sentences.  Do whatever is needed
  ProcessResults(ls);

}
```

The processing performed on the obtained results would obviously depend on the goal of the application (translation, indexation, etc.). In order to illustrate the structure of the linguistic data objects, a simple procedure is presented below, in which the processing consists of merely printing the results to stdout in XML format.

```C++
void ProcessResults(const list<sentence> &ls) {

  list<sentence>::const_iterator is;
  word::const_iterator a;   //iterator over all analysis of a word
  sentence::const_iterator w;

  // for each sentence in list
  for (is=ls.begin(); is!=ls.end(); is++) {

    wcout<<L"<SENT>"<<endl;
    // for each word in sentence
    for (w=is->begin(); w!=is->end(); w++) {

      // print word form, with PoS and lemma chosen by the tagger
      wcout<<L"  <WORD form=\""<<w->get_form();
      wcout<<L"\" lemma=\""<<w->get_lemma();
      wcout<<L"\" pos=\""<<w->get_tag();
      wcout<<L"\">"<<endl;

      // for each possible analysis in word, output lemma, tag and probability
      for (a=w->analysis_begin(); a!=w->analysis_end(); ++a) {
         // print analysis info
         wcout<<L"    <ANALYSIS lemma=\""<<a->get_lemma();
         wcout<<L"\" pos=\""<<a->get_tag();
         wcout<<L"\" prob=\""<<a->get_prob();
         wcout<<L"\"/>"<<endl;
      }

      // close word XML tag after list of analysis
      wcout<<L"  </WORD>"<<endl;
    }

    // close sentence XML tag
    wcout<<L"</SENT>"<<endl;
  }
}
```

The above sample program may be found in `src/main/simple_examples/sample.cc<` in FreeLing tarball. The actual program also outputs tree structures resulting from parsing, which is ommitted here for simplicity.

Once you have compiled and installed FreeLing, you can build this sample program (or any other you may want to write) with the command: `g++ -o sample sample.cc -lfreeling`

Option `-lfreeling` links with libfreeling library, which is the final result of the FreeLing compilation process. Check the README file in the directory to learn more about compiling and using the sample programs.

You may need to add some `-I` and/or `-L` options to the compilation command depending on where the headers and code of required libraries are located. For instance, if you installed some of the libraries in `/usr/local/mylib` instead of the default place `/usr/local`, you'll have to add the options `-I/usr/local/mylib/include -L/usr/local/mylib/lib` to the command above.

Executing `make` in `/src/main/simple_examples` will compile all sample programs in that directory. Make sure that the paths to FreeLing installation directory in `Makefile` are the right ones.
