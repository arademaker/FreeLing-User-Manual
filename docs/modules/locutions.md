# Multiword Recognition Module {#multiword-recognition-module}

This module aggregates input tokens in a single word object if they
are found in a given list of multiwords.

The API for this class is:

```C++
class locutions: public automat {
  public:
    /// Constructor, receives the name of the file
    /// containing the multiwords to recognize.
    locutions(const std::string &cfgfile);

    /// Detect multiwords starting at given sentence position
    bool matching(sentence &s, sentence::iterator &p);

    /// set "OnlySelected" flag on/off
    void set_OnlySelected(bool b);

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

Class `automat` implements a generic ATN. The `locutions` class is a
derived class which implements an ATN to recognize the word patterns
listed in the file given to the constructor.

## Multiword Definition File {#multiword-definition-file}

The file contains a list of multiwords to be recognized.

The file consists of three sections `<TagSetFile>`, `<OnlySelected>`,
and `<Multiwords>`. All of them are optional (though an empty or
unexisting `<Multiwords>` section will result in never detecting any
multiword).

Section `<TagSetFile>`. This section contains a single line with the
path to a [tagset description file](tagset.md) to be used when
computing short versions for PoS tags. If the path is relative, the
location of the multiwords file is used as the base directory.

Section `<OnlySelected>` contains a single line with the one of the
words `yes`, `true`, `no`, or `false`. If the section is ommited, or
contains any unknown value, the value defaults to `false`.

This flag controls the analysis that the multiword detector will
consider when matching a multiwords pattern that contains lemmas or
PoS descriptions. If `OnlySelected=` is set to `false` (the default)
all possible analysis for each word will matched against the
pattern. If `OnlySelected` is set to `true`, only selected analysis
will be checked. Note that setting `OnlySelected` to `true` only makes
sense if the multiwords module is applied after the PoS tagger, since
otherwise no analysis will be selected.

Section `<Multiwords>` contains one multiword pattern per line. Each
line has the format: `form lemma1 pos1 lemma2 pos2 ... [A|I]`

The multiword form may contain lemmas in angle brackets, meaning that any form with that lemma will be considered a valid component for the multiword.

The form may also contain PoS tags. Any uppercase component in the
form will be treated as a PoS tag.

Any number of pairs lemma-tag may be assigned to the multiword. The
PoS tagger will select the most probable given the context, as with
any other word.

For instance:

```
a_buenas_horas a_buenas_horas RG A
a_causa_de a_causa_de SPS00 I
<accidente>_de_trabajo accidente_de_trabajo $1:NC I
<acabar>_de_VMN0000 acabar_de_$L3 $1:VMI I
Z_<vez> TIMES:$L1 Zu I
NC_SP_NC $L1_$L2_$L3 $1:NC I
```

The tag may be specified directly, or as a reference to the tag of
some of the multiword components. In the previous example, the third
multiword specification will build a multiword with any of the forms
_accidente de trabajo_ or _accidentes de trabajo_. The tag of the
multiword will be that of its first form (`$1`) which starts with
`NC`. This will assign the right singular/plural tag to the multiword,
depending on whether the form was _accidente_ or _accidentes_.

The lemma of the multiword may be specified directly, or as a
reference to the form of lemma of some of the multiword components. In
the previous example, the fourth multiword specification will build a
multiword with phrases such as _acabo de comer_, _acababa de salir_,
etc. The lemma will be `acabar_de_XXX` where `XXX` will be replaced
with the lemma of the third multiword component (`$L3`).

The pattern can also depict PoS values for some components of the
multiword. For instance, the second-to-last multiword above will
detect any combination where the first word has PoS `Z`, and the
second word has lemma _vez_ (e.g _una vez_, _6 veces_, _cuarenta y dos
veces_, etc.)

The last example pattern will capture any trigram where the first and
third words are nouns (`NC`) and the middle word is a preposition
(`SP`), e.g. _base de datos_, _compuesto de penicilina_, etc.

Note that patterns that specify lemmas or PoS will behave different
depending on the value of the flag `OnlySelected` described above.

Lemma replacement strings can be `$F1`, `$F2`, `$F3`, etc. to select
the lowercased form of any component, or `$L1`, `$L2`, `$L3`, etc. to
select the lemma of any component. Component numbers can range from 1
to 9.

The last field states whether the multiword is ambiguous `A` or not
`I` with respect to its segmentation (i.e. that it may be a multiword
or not, depending on the context). The multiword is built in any case,
but the ambiguity information is stored in the `word` object, so the
calling applicacion can consult it and take the necessary decisions
(e.g. un-glue the multiword) if needed.
    
Note that the described format allows only to encode multiwords whose
components are adjacent.  Non-adjacent multiwords are not supported.
