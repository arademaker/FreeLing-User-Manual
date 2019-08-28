
# Language Identifier Module {#language-identifier-module}

This module is somehow different of the other modules, since it doesn't enrich the given text. It compares the given text with available models for different languages, and returns the most likely language the text is written in. It can be used as a preprocess to determine which data files are to be used to analyze the text.

The API of the language identifier is the following:

```C++
class lang_ident {
  public:
    /// Build an empty language identifier.
    lang_ident();

    /// Build a language identifier, read options from given file.
    lang_ident(const std::wstring &cfgfile);

    /// load given language from given model file, add to existing languages.
    void add_language(const std::wstring &modelfile);
    
    /// train a n-gram model of given order for language 'code', 
    /// store in modelFile, and add it to the known languages list.
    void train_language(const std::wstring &textfile, 
                        const std::wstring &modelfile, 
                        const std::wstring &code, size_t order);

    /// Classify the input text and return the code of the best language among
    /// those in given set. If set is empty all known languages are considered.
    /// If no language reaches the threshold,  "none" is returned
    std::wstring identify_language (
                   const std::wstring&, 
                   const std::set<std::wstring> &ls) const; 
                   
    /// Classify the input text and return the code and perplexity for 
    /// each language in given set. If set is empty, all known languages 
    /// are considered.
    void rank_languages (
               std::vector<std::pair<double,std::wstring> > &result, 
               const std::wstring &text,
               const std::set<std::wstring> &ls) const;


};
```

Once created, the language identifier may be used to get the most likely language of a text using the method `identify_language`, or to return a sorted vector of probabilities for each language (`rank_languages`). In both cases, a set of languages to be considered may be supplied, telling the identifier to apply to the input text only models for those languages in the list. An empty list is interpreted as *use all available language models*. The language list parameter is optional in both identification methods, and defaults to the empty list.

The same `lang_ident` class may be used to train models for new languages. A plain text file can be passed to method `train_language` which will use the data to create a new model, which will enlarge the identifier's language repertoire, and will be stored for its use in future instances of the class.

The constructor expects a configuration file name, containing information about where are the language models located, and some parameters. The contents of that file are described below.

## Language Identifier Options File {#language-identifier-options-file}

The language identifier options file has a unique section `<Languages>` closed by tag `</Languages>`.

Section `<Languages>` contains a list of filenames, one per line. Each filename contains a language model (generated with the `train_language` method). The filenames may be absolute or relative. If relative, they are considered to be relative to the location of the identifier options file.

An example of a language identifier option file is:

```XML
<Languages>
./es.dat
./ca.dat
./it.dat
./pt.dat
</Languages>
```
