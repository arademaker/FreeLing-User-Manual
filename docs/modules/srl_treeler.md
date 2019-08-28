
# Semantic Role Labelling Module

Semantic Role Labelling module is a machine-learning based classifier following the proposal by [\[LCM\]](../references.md).

The API of the class is the following:

```C++
class srl_treeler : public freeling::srl_parser {
 public:   
   /// constructor
   srl_treeler(const std::string &cfgfile);
   /// destructor
   ~srl_treeler();

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

The constructor for class `srl_treeler` expects a configuration file with the contents described below.

The module can performs semantic role labelling (SRL), and requires that a dependency parsing has been already applied on the input sentences.


## SRL Configuration File

The configuration file for the semantic role labelling module has a single section `<SRL>`, containing keyword-value lines, which may be of 4 different types:

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
