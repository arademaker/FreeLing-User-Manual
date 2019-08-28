
# Statistical Dependency Parser and Semantic Role Labelling Module

As an alternative to rule-based Txala dependency parser, a statistical dependency parsing module is also available. 
It is based on [Treeler](http://devel.cpl.upc.edu/treeler) machine learning library.

The dependency parser is based on the paper [\[Car07\]](../references.md).

The API of the class is the following:

```C++
class dep_treeler : public dependency_parser {
 public:   
   /// constructor
   dep_treeler(const std::string &cfgfile);
   /// destructor
   ~dep_treeler();

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

The constructor for class `dep_treeler` expects a configuration file with the contents described below.


## Statistical Parser Configuration File

The configuration file for the statistical dependency parser and semantic role labelling module has a single section `<Dependencies>`, containing two lines, with a keyword and a value each:

* The `DependencyTreeler` keyword should be followed by a path to a Treeler configuration file with the dependency parsing model to use. The path may be either absolute or relative to the Statistical Parser configuration file.

* The `Tagset` keyword should be followed by a path to a [tagset definition](tagset.md) file which will be used to convert the input PoS tags to the short versions and MSD features expected by the Treeler model.

An example of the `<Dependencies>` section:
```XML
<Dependencies>
## treeler config file for dep parser
DependencyTreeler ./dep/config.dat

## Tagset description file
Tagset ./tagset.dat
</Dependencies>
```

