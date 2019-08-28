
# Tag Set Managing Module {#tag-set-managing-module}

This module is able to store information about a tagset, and offers some useful functions on PoS tags and morphological features.

This module is internally used by some analyzers (e.g. probabilities module, HMM tagger, feature extraction, ...) but can be instantiated and called by any user application that requires it.

The API of the module is:

```C++
class tagset {

  public:
     /// constructor: load a tag set description file
     tagset(const std::wstring &f);
     /// destructor
     ~tagset();

     /// get short version of given tag
     std::wstring get_short_tag(const std::wstring &tag) const;
     /// get map of <feature,value> pairs with morphologica information for given tag
     std::map<std::wstring,std::wstring> 
                 get_msd_features_map(const std::wstring &tag) const;
     /// get list of <feature,value> pairs with morphologica information for given tag
     std::list<std::pair<std::wstring,std::wstring> > 
           get_msd_features(const std::wstring &tag) const;
     /// get a string with <feature,value> pairs with morphologica information for given tag
     std::wstring get_msd_string(const std::wstring &tag) const;
    
     /// convert list of <feature,value> pairs to a PoS tag. 
     /// if the list does not contain a value for feature 'pos', the category must be
     /// scpecified in the 'cat' parameter. Valid categories are those defined in the 
     /// tagset description file loaded by the constructor.
     std::wstring 
        msd_to_tag(const std::wstring &cat,
                   const std::list<std::pair<std::wstring,std::wstring> > &msd) const;

     /// convert string of <feature,value> pairs to a PoS tag. 
     /// if the list does not contain a value for feature 'pos', the category must be
     /// scpecified in the 'cat' parameter. Valid categories are those defined in the 
     /// tagset description file loaded by the constructor.
     std::wstring msd_to_tag(const std::wstring &cat,const std::wstring &msd) const;
};
```

The class constructor receives a file name with a tagset description. Format of the file is described below. The class offers three kinds of services:

1.  Get the short version of a tag. This is useful for EAGLES tagsets, and required by some modules (e.g. PoS tagger). The length of a short tag is defined in the tagset description file, and depends on the language and part-of-speech. The  criteria to select it is usually to have a tag informative enough (capturing relevant features such as category, subcategory, case, etc) but also general enough so that significative statistics for PoS tagging can be acquired from reasonably-sized corpora. For instance, in latin languages the PoS tag for nouns includes gender and number information (e.g. `NCMS000`), but using the whole tag results in statistical dispersion when estimating tagger or parser probabilities. So, the short version `NC` is used. Tagset description file defines which digits should be extracted from the full tag to build the short version.

2.  Decompose a tag into a list of pairs feature-value (e.g. <tt>gender=masc</tt>, <tt>num=plural</tt>, <tt>case=dative</tt>, etc). This can be retrieved as a map, as a list of string pairs, or as a formatted string.

3.  Given a list of pairs feature-value for morphological attributes, return a PoS tag encoding those properties.


## Tagset Description File {#tagset-description-file}

Tagset description file has two sections: `<DecompositionRules>` and `<DirectTranslations>`, which describe how tags are converted to their short version and decomposed into morphological feature-value pairs

*   Section `<DirectTranslations>` describes a direct mapping from a tag to its short version and to its feature-value pair list. Each line in the section corresponds to a tag, and has the format:  
    `tag short-tag feature-value-pairs`

    For instance the line:  
    `NCMS000 NC postype=common|gender=masc|number=sing`
    states that the tag `NCMS000` is shortened as `NC` and that its list of feature-value pairs is the one specified.

    This section has precedence over section `<DecompositionRules>`, and can be used as an exception list. If a tag is found in section `<DirectTranslations>`, the rule is applied and any rule in section `<DecompositionRules>` for this tag is ignored.

*   Section `<DecompositionRules>` encodes rules to compute the morphological features from an EAGLES label. The rules describe the possible values and meaning of each position in the label. The form of each line is:  
    `tag short-tag-size category position-description-1 position-description-2 ...`  
    where `tag` is the character for the category in the EAGLES PoS tag (i.e. the first character: `N`, `V`, 
    `A`, etc.), and `short-tag-size` is an integer stating the length of the short version of the tag (e.g. if the value is 2, the first two characters of the EAGLES PoS tag will we used as short version). 
    `Category`is the name of the main category (e.g. <tt>noun</tt>, <tt>verb</tt>, etc.).  

    Finally, fields `position-description-n` contain information on how to interpret each character in the EAGLES PoS tag.  
    There should be as many `position-description` fields as characters there are in the PoS tag for that category. Each `position-description` field has the format:   
    `feature/char:value;char:value;char:value;...`   
    That is: the name of the feature encoded by that character (e.g. <tt>gender</tt>, <tt>number</tt>, etc.) followed by a slash, and then a semicolon-separated list of translation pairs that, for each possible character in that position give the feature value.

    For instance, the rule for Spanish noun PoS tags is (in a single line):   
    `N 2 noun type/C:common;P:proper gen/F:fem;M:masc;C:common num/S:sing;P:plur;N:inv neclass/S:person;G:location;O:organization;V:other grade/V:evaluative`  
    and states that any tag starting with <tt>N</tt> (unless it is found in section `<DirectTranslations>`) will be shortened using its two first characters (e.g. <tt>NC</tt>, or <tt>NP</tt>). Then, the description of each character in the tag follows, encoding the information:

    1.  `type/C:common;P:proper` - second digit is the subcategory (feature <tt>type</tt>) and its possible values are `C` (translated as <tt>common</tt>) and `P` (translated as <tt>proper</tt>).
    2.  `gen/F:fem;M:masc;C:common` - third digit is the gender (feature <tt>gen</tt>) and its possible values are `F` (feminine, translated as <tt>fem</tt>), `M` (masculine, translated as <tt>masc</tt>), and <tt>C</tt> (common/invariable, translated as <tt>common</tt>).
    3.  `num/S:sing;P:plur;N:inv` - fourth digit is the number (feature <tt>num</tt>) and its possible values are `S` (singular, translated as <tt>sing</tt>), `P` (plural, translated as <tt>plur</tt>), and <tt>N</tt> (common/invariable, translated as <tt>inv</tt>).
    4.  `neclass/S:person;G:location;O:organization;V:other` - Fifth digit is the semantic class for proper nouns (feature <tt>neclass</tt>), with possible values `S` (translated as <tt>person</tt>), `G` (translated as <tt>location</tt>), `O` (translated as <tt>organization</tt>), and `V` (translated as <tt>other</tt>).
    5.  `grade/V:evaluative` - sixth digit is the grade (feature <tt>grade</tt>) with possible values `V` (translated as <tt>evaluative</tt>).

    If a feature is underspecified or not appliable, a zero (<tt>0</tt>) is expected in the appropriate position of the PoS tag.

    The following tag translations would result of the example rule described above:

| EAGLES | PoS tag short version | morphological features |
|:------:|:-------               |:------------           |
| NCMS00 | NC                    | pos=noun, type=common, gen=masc, num=sing |
| NCFC00 | NC                    | pos=noun, type=common, gen=fem, num=common | 
| NCFP00 | NC                    | pos=noun, type=common, gen=fem, num=plur, grade=evaluative |
| NP0000 | NP                    | pos=noun, type=proper |
| NP00G0 | NP                    | pos=noun, type=proper, neclass=location |

