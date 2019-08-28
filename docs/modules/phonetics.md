# Phonetic Encoding Module {#phonetic-encoding-module}

The phonetic encoding module enriches words with their [SAMPA phonetic codification](http://www.phon.ucl.ac.uk/home/sampa).

The module applies a set of rules to transform the written form to the output phonetic form, thus the rules can be changed to get the output in any other phonetic alphabet. The module can also use an exception dictionary to handle forms that do not follow the default rules, or for languages with highly irregular ortography.

The API of the module is the following:

```C++
class phonetics {

 public:
  /// Constructor, given config file
  phonetics(const std::wstring &cfgfile);

  /// Returns the phonetic sound of the word
  std::wstring get_sound(const std::wstring &form) const;

  /// analyze given sentence, enriching words with phonetic encoding
  void analyze(sentence &s) const;

  /// analyze given sentences
  void analyze(std::list<sentence> &ls) const;

  /// analyze sentence, return analyzed copy
  sentence analyze(const sentence &s) const;

  /// analyze sentences, return analyzed copy
  std::list<sentence> analyze(const std::list<sentence> &ls) const;
};
```

The constructor receives a configuration file that contains the transformation rules to apply and the exception dictionary.

The module can be used to transform a single string (method `get_sound`) or to enrich all words in a sentence (or sentence list) with their phonetic information.

The phonetic encoding is stored in the `word` object and can be retrieved using the method `get_ph_form` in the `word` class.

## Phonetic encoder configuration file:

The configuration file contains two kinds of sections:

* Section `<Exceptions>` contains an exception dictionary. This section is optional, and if it occurs, it must be just once.  
  Each entry in the exception dictionary contains two fields: a lowercase word form and the output phonetic encoding.  
  E.g.:
  ```
  addition @dISIn
  varieties B@raIItiz
  worcester wUst@r
  ```

  If a word form is found in the exceptions dictionary, the corresponding phonetic string is returned and no transformation rules are applied.

* Section `<Rules>` contain transformation rules that convert from orthogaphic to phonetic writting.  
  The file may contain one or more rulesets delimited by `<Rules>` and `</Rules>`. Rulesets are applied in the order they are defined. Each ruleset is applied on the result of the previous.

  Rulesets can contain two kind of lines: Category definitions and rules.

    * Category definitions are of the form `X=abcde` and define a set of characters under a single name. Category names must have exactly one character, which should not be part of the input or output alphabet to avoid ambiguities. e.g.:
    ```
    U=aeiou
    V=aeiouäëïöüâêîôûùò@
    L=äëïöüäëïöüäëïöüùò@
    S=âêîôûâêîôûâêîôûùò@
    A=aâä
    E=eêë
    ``` 

    Categories are only active for rules in the same ruleset where the category is defined.

    * Rules have the form: `source/target/context`.  
      Both `source` and `target` may be either a category name or a terminal string.

      Simple string rules replace the `source` string with the `target` string if and only if it occurs in the given `context`.

      Contexts must contain a `_` symbol indicating where the source string is located. They may also contain characters, categories, and the symbols `^` (word beginning), or `$` (word end). The empty context `_` is always satisfied.

      Rules can only change terminal strings to terminal strings, or categories to categories (i.e. both `source` and `target` have to be of the same type). If a category is to be changed to another category, they should contain the same number of characters. Otherwise the second category will have its last letter repeated until it has the same length as the first (if it is shorter), or characters in the second category that don't match characters in the first will be ignored.

      Some example rules for English:

      ```
      qu/kw/_
      h//^r_
      a/ò/_lmV$
      U/L/C_CV
      ```

      The first rule `qu/kw/_` replaces string `qu` with `kw` in any context. 

      The second rule `h//^r_` removes character `h` when it is preceeded by `r` at word beginning. 

      Rule `a/ò/_lmV$` replaces `a` with `ò` when followed by `l`, `m`, or any character in category `V` at the end of the word. 

      Rule `U/L/C_CV` replaces any character in category `U` with the character in the same position in category `L`, when preceeded by any character in category `C` and followed by any character in category `C` plus any character in category `V`.

      Note that uppercase characters for categories is just a convention. An uppercase letter may be a terminal symbol, and a lowercase may be a category name. Non-alphabetical characters are also allowed. If a character is not defined as a category name, it will be considered a terminal character.
