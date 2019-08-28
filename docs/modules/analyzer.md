# Analyzer Metamodule {#analyzer-metamodule}

Although FreeLing is a toolbox with a variety of modules to pick and choose from for specific uses, most applications are likely to need a text analisys pipeline that goes from raw text to certain level of annotation.

To ease the construction of applications that call FreeLing, the <tt>analyzer</tt> metamodule has been included. This metamodule implements a pipeline calling a standard sequence of FreeLing modules: Tokenizer, splitter, morphological analyzer, PoS tagger, sense annotation, WSD, NEC, parsing, SRL, coreferences.

A set of customizable options in this module allows the calling application to control the start and ending levels of the pipeline (e.g. from text to shallow parsing, or from tagged input to coreferences...), as well as which modules are turned on/off and with which configuration files are they loaded.

Thus, different instances of this class can be created using different option sets to get analyzers for different languages or different tasks.

The API of the class is the following:

```C++
class analyzer {
 public:
   typedef analyzer_config_options config_options;
   typedef analyzer_invoke_options invoke_options;

   /// constructor, given a set of creation options
   analyzer(const config_options &cfg);

   /// Destructor
   ~analyzer();

   /// get current execution options
   const invoke_options& get_current_invoke_options() const;

   /// change execution options for next call
   void set_current_invoke_options(const invoke_options &opt, bool check=true);

   /// analyze text as a whole document.
   /// 'parag' indicates whether a blank line is to be considered a paragraph 
   /// separator.
   void analyze(const wstring &text, document &doc, bool parag=false) const;

   /// Analyze text as a partial document. Retain incomplete sentences in buffer   
   /// in case next call completes them (except if flush==true)
   void analyze(const wstring &text, std::list<sentence> &ls, bool flush=false);

   /// analyze further levels on a partially analyzed document
   void analyze(document &doc) const;

   /// analyze further levels on partially analyzed sentences
   void analyze(std::list<sentence> &ls) const;

   /// flush splitter buffer and analyze any pending text. 
   void flush_buffer(std::list<sentence> &ls);

   /// Reset tokenizer byte offset counter to 0.
   void reset_offset();
};
```

The constructor expects a set of configuration options (see `class analyzer::config_options` below) which specifiy creation-time options for all modules that need to be loaded. These options are basically configuration and data files to load.

The `analyzer` meta-module will create all modules for which a configuration file is specified. If a module does not need to be created, the corresponding option in `analyzer::config_options` should be empty.

Once the `analyzer` instance is created, a set of invocation options must be specified (see description of class `analyzer::invoke_options` below) . Invocation options are run-time options and can be altered for each analysis if necessary (e.g. if one needs to apply different processes to different kinds of input texts). They include activating/deactivating modules or changing the initial/final points in the pipeline.

When invoke options are set, the `analyzer` meta-module can be called to process a plain text, or to enrich a partially analyzed document.

## Analyzer configuration options {#analyzer-configuration-options}

Class `analyzer::config_options` contains the configuration options that define which modules are active and which configuration files are loaded for each of them at construction time. Options in this set can not be altered once the analyzer is created. If an option has an empty value, the corresponding module will not be created (and thus it will not be possible to call it just altering `invoke_options` later)

```C++
class analyzer::config_options {
  public:
     /// Language of text to process
     std::wstring Lang;

     /// Tokenizer configuration file
     std::wstring TOK_TokenizerFile;

     /// Splitter configuration file
     std::wstring SPLIT_SplitterFile;

     /// Morphological analyzer options
     std::wstring MACO_Decimal, MACO_Thousand;
     std::wstring MACO_UserMapFile, MACO_LocutionsFile,   MACO_QuantitiesFile,
                  MACO_AffixFile,   MACO_ProbabilityFile, MACO_DictionaryFile, 
                  MACO_NPDataFile,  MACO_PunctuationFile, MACO_CompoundFile;   	 
     double MACO_ProbabilityThreshold;

     /// Phonetics config file
     std::wstring PHON_PhoneticsFile;

     /// NEC config file
     std::wstring NEC_NECFile;

     /// Sense annotator and WSD config files
     std::wstring SENSE_ConfigFile;
     std::wstring UKB_ConfigFile;

     /// Tagger options
     std::wstring TAGGER_HMMFile;
     std::wstring TAGGER_RelaxFile;
     int TAGGER_RelaxMaxIter;
     double TAGGER_RelaxScaleFactor;
     double TAGGER_RelaxEpsilon;
     bool TAGGER_Retokenize;
     ForceSelectStrategy TAGGER_ForceSelect;

     /// Chart parser config file
     std::wstring PARSER_GrammarFile;

     /// Dependency parsers config files
     std::wstring DEP_TxalaFile;   
     std::wstring DEP_TreelerFile;   

     /// Coreference resolution config file
     std::wstring COREF_CorefFile;

     /// semantic graph extractor config file
     std::wstring SEMGRAPH_SemGraphFile;
};
```

## Analyzer invocation options {#analyzer-invocation-options}

Class `analyzer::invoke_options` contains the options that define the behaviour of each module in the analyze on the all subsequent analysis (until invoke options are changed again) Options in this set can be altered after construction (e.g. to activate/deactivate certain modules), as many times as needed.

Values for this options need to be consistent with configuration options used to create the analyzer (e.g. it is not possible to activate a module that has not been loaded at creation time)

```C++
class analyzer_invoke_options {
   public:
     /// Level of analysis in input and output
     AnalysisLevel InputLevel, OutputLevel;

     /// activate/deactivate morphological analyzer modules
     bool MACO_UserMap, MACO_AffixAnalysis, MACO_MultiwordsDetection, 
          MACO_NumbersDetection, MACO_PunctuationDetection, 
          MACO_DatesDetection, MACO_QuantitiesDetection, 
          MACO_DictionarySearch, MACO_ProbabilityAssignment, MACO_CompoundAnalysis,
          MACO_NERecognition, MACO_RetokContractions;

     /// activate/deactivate phonetics
     bool PHON_Phonetics;

     /// activate/deactivate NEC
     bool NEC_NEClassification;

     /// Select which WSD to use (NO_WSD,ALL,MFS,UKB)
     WSDAlgorithm SENSE_WSD_which;

     /// Select which tagger to use (NO_TAGGER,HMM,RELAX)
     TaggerAlgorithm TAGGER_which;

     /// Select which dependency parser to use (NO_DEP,TXALA,TREELER)
     DependencyParser DEP_which;    
};
```

