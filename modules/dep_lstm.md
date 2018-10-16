
# Neural Dependency Parser {#neural-dependency-parser}

As an alternative to rule-based Txala dependency parser and `dep_treeler` statistical parser, a neural-network based dependency parsing module is also available. 
It is based on the LSTM parser proposed by [\[DBL+15\]](../references.md).

The API of the class is the following:

```C++
class dep_lstm : public dependency_parser {
 public:   
   /// constructor
   dep_lstm(const std::string &cfgfile);
   /// destructor
   ~dep_lstm();

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

## Neural Parser Configuration File {#neural-parser-configuration-file}

The constructor for class `dep_lstm` expects a configuration file, which is created by the training scripts. 
Attempts to customize it will result in a poor performance.

