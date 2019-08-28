
# Statistical Dependency Parser and Semantic Role Labelling Module {#statistical-dependency-parser-and-semantic-role-labelling-module}

As an alternative to rule-based Txala dependency parser, a statistical dependency parsing module is also available. 
It is based on [Treeler](http://devel.cpl.upc.edu/treeler) machine learning library.

The dependency parser is based on the paper [\[Car07\]](../references.md), and the Semantic Role Labelling module follows the proposal by [\[LCM\]](../references.md).

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

The module can perform not only dependency parsing, but also semantic role labelling (SRL) if it has been trained to do so.

The configuration file establishes whether both tasks are performed, or just dependency parsing.


## Statistical Parser and SRL Configuration File {#statistical-parser-and-srl-configuration-file}

The configuration file for the statistical dependency parser and semantic role labelling module has two main sections: `<Dependencies>` and `<SRL>`. Each section establishes the configuration and parameters of the corresponding subtask. Section `<Dependencies>` is required, but section `<SRL>` may be ommitted if no SRL is required.

Section `<Dependencies>` contains two lines, with a keyword and a value each:

* The `DependencyTreeler` keyword should be followed by a path to a Treeler configuration file with the dependency parsing model to use. The path may be either absolute or relative to the Statistical Parser and SRL configuration file.

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

Section `<SRL>` contains also keyword-value lines, which may be of 4 different types:

*   `Predicates`: Lines stating a PoS tag and a list of files containing lines with the format:  
    `sense predicate argument1 argument2 ... [*]`  
    E.g.
    ```
    00028565-v smile.01 A0:Agent A1:Theme A2:Recipient
    00008435-v wink.01|blink.01 A0:Agent A1:Patient A2:Recipient A3:Theme
    00014201-v shudder.01|shiver.01 A1:Experiencer A2:Stimulus
    ```

    If the word sense is contained in one of the lists, the word is considered as a predicate for SRL, and its sense number and argument pattern are retrieved from the list. 

    An asterisk may be added to the end of the line indicating that words not found in any list, but with the appropriate PoS, should be considered predicates too.

*   `PredicateException`: This lines list specific cases of words that should not be considered predicates, even if they satisfy some of the conditions of a `Predicates` line. An additional PoS may be added, meaning that the exception holds only if the target word has a dependant with that PoS. This is typically used to exclude auxiliary verbs from being considered predicates (e.g. if there is a `Predicates` rule that would consider any verb as a predicate, auxiliary verbs that have another verb as dependant are not to be considered as predicates).

*   `DefaultArgs`: List of labels for the argument frame to be used for predicates not found in any list (but considered predicates because some `Predicates` line had an asterisk).

*   `SRLTreeler`: This keyword must be followed by a path to a Treeler configuration file with the SRL model to use. The path may be either absolute or relative to the Statistical Parser and SRL configuration file.

An example of the `<SRL>` section:
```XML
<SRL>
## Files containing conversion synset->predicate->argument list
## Each PoS admits a list of files, checked in cascade.
## Asterisc means any word with that PoS will be a predicate, 
## even if it is not in any list. In that case, predicate  number 
## will be ``.00'' and arguments will be those in ``DefaultArgs''
Predicates V ../../common/pred-verb.dat *
Predicates N ../../common/pred-nom.dat

## Execptions: words that are NOT predicates, even if they are 
## accepted by rules above (e.g. matched an asterisc). 
## The execption holds only if the word has a daugher with given PoS.
PredicateException V:have V
PredicateException V:be V
PredicateException V:do V

## arguments for predicates not found in the list (e.g. accepted
## by an asterisc)
DefaultArgs A0 A1 A2 A3

## If you do not need SRL, comment out SRLTreeler line or remove section <SRL>
## treeler config file for SRL
SRLTreeler ./srl/config.dat
</SRL>
```
