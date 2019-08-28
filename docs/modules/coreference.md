
# RelaxCor Coreference Resolution Module {#relaxcor-coreference-resolution-module}

This module offers coreference resolution capabilities.

It is based on the research described in [\[Sap13\]](../references.md), the second-ranked system at CoNLL 2011 shared task.

The API to this module is:

```C++
class relaxcor {
  public:

    /// Constructor
    relaxcor(const std::wstring &fconfig);
    /// Destructor
    ~relaxcor();

   /// Finds the coreferent mentions in a document
    void analyze(document&) const;
  };
```

The module constructor expects a configuration file that define which resources to load and parameters to use. This file also defines which are the configuration files for several sub-modules (mention detection, feature extraction, etc).

Once created, the module can be given a document (which in general should be fully analyzed with shallow parsing, dependency parsing, NEC, WSD, and SRL) and it will enrich the document metadata with coreference information.

Note that this module can only process whole documents, and not single sentences or paragraphs as the other modules, since coreference is a document-level phenomenon.
