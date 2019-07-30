# Quantity Recognition Module {#quantity-recognition-module}

The <tt>quantities</tt> class is an ATN that recognizes ratios, percentages, and physical or currency magnitudes (e.g. twenty per cent, 20%, one out of five, 1/5, one hundred miles per hour, etc.

This module depends on the [numbers detection](numbers.md) module. If numbers are not previously detected and annotated in the sentence, quantities will not be recognized.

This module, similarly to number recognition, is language dependent: That is, an ATN has to be programmed to match the patterns of ratio expressions in that language.

Currency and physical magnitudes can be recognized in any language, given the appropriate data file.

```C++
class quantities {
  public:
    /// Constructor: receives the language code, and the data file.
    quantities(const std::string &lang, const std::string &cfgfile); 

    /// Detect magnitude expressions starting at given sentence position
    bool matching(sentence &s, sentence::iterator &p) const;

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

## Quantity Recognition Data File {#quantity-recognition-data-file}

This file contains the data necessary to perform currency amount and physical magnitude recognition. It consists of three sections: `<Currency>`, `<Measure>`, and `</MeasureNames>`.

Section `<Currency>` contains a single line indicating which is the code, among those used in section `<Measure>`, that stands for 'currency amount'. This is used to assign to currency ammounts a different PoS tag than physical magnitudes. E.g.:

```XML
<Currency>
CUR
</Currency>
```

Section `<Measure>` indicates the type of measure corresponding to each possible unit. Each line contains two fields: the measure code and the unit code. The codes may be anything, at user's choice, and will be used to build the lemma of the recognized quantity multiword.

E.g., the following section states that <tt>USD</tt> and <tt>FRF</tt> are of type <tt>CUR</tt> (currency), <tt>mm</tt> is of type <tt>LN</tt> (length), and <tt>ft/s</tt> is of type <tt>SP</tt> (speed):

```XML
<Measure>
CUR USD
CUR FRF
LN mm
SP ft/s
</Measure>
```

Finally, section `<MeasureNames>` describes which multiwords have to be interpreted as a measure, and which unit they represent. The unit must appear in section `<Measure>` with its associated code. Each line has the format: `multiword_description code tag` where:

* `multiword_description` is a multiword pattern as used in the [multiwords detection](locutions.md) file 
* `code` is the type of magnitude the unit describes (currency, speed, etc.)
* `tag` is a constraint on the lemmatized components of the multiword, following the same conventions than in [multiwords detection](locutions.md) file.

E.g.,
```
<MeasureNames>
french_<franc> FRF $2:N
<franc> FRF $1:N
<dollar> USD $1:N
american_<dollar> USD $2:N
us_<dollar> USD $2:N
<milimeter> mm $1:N
<foot>_per_second ft/s $1:N
<foot>_Fh_second ft/s $1:N
<foot>_Fh_s ft/s $1:N
<foot>_second ft/s $1:N
</MeasureNames>
```

This section will produce results such as the following:

```
234_french_francs CUR_FRF:234 Zm
one_dollar CUR_USD:1 Zm
two_hundred_fifty_feet_per_second SP_ft/s:250 Zu
```

Quantity multiwords will be recognized only when following a number, that is, in the sentence _They got a lot of french francs_, the multiword <tt>french_francs</tt> won't be recognized since the sentence is specifying determined quantity of that measure unit.

It is important to note that the lemmatized multiword expressions (the ones that containt angle brackets) will only be recognized if the lemma is present in the dictionary with its corresponding inflected forms.
