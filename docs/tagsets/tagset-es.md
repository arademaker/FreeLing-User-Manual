## Tagset for Spanish (es)


### Part of Speech: `adjective`
| Position | Atribute | Values |
|:----     |:----     |:----   |
| 0        | category | **A**:_adjective_ |
| 1 | type |   **O**:_ordinal_;   **Q**:_qualificative_;   **P**:_possessive_|
| 2 | degree |   **S**:_superlative_;   **V**:_evaluative_|
| 3 | gen |   **F**:_feminine_;   **M**:_masculine_;   **C**:_common_|
| 4 | num |   **S**:_singular_;   **P**:_plural_;   **N**:_invariable_|
| 5 | possessorpers |   **1**:_1_;   **2**:_2_;   **3**:_3_|
| 6 | possessornum |   **S**:_singular_;   **P**:_plural_;   **N**:_invariable_|

### Part of Speech: `conjunction`
| Position | Atribute | Values |
|:----     |:----     |:----   |
| 0        | category | **C**:_conjunction_ |
| 1 | type |   **C**:_coordinating_;   **S**:_subordinating_|

### Part of Speech: `determiner`
| Position | Atribute | Values |
|:----     |:----     |:----   |
| 0        | category | **D**:_determiner_ |
| 1 | type |   **A**:_article_;   **D**:_demonstrative_;   **I**:_indefinite_;   **P**:_possessive_;   **T**:_interrogative_;   **E**:_exclamative_|
| 2 | person |   **1**:_1_;   **2**:_2_;   **3**:_3_|
| 3 | gen |   **F**:_feminine_;   **M**:_masculine_;   **C**:_common_|
| 4 | num |   **S**:_singular_;   **P**:_plural_;   **N**:_invariable_|
| 5 | possessornum |   **S**:_singular_;   **P**:_plural_;   **N**:_invariable_|

### Part of Speech: `noun`
| Position | Atribute | Values |
|:----     |:----     |:----   |
| 0        | category | **N**:_noun_ |
| 1 | type |   **C**:_common_;   **P**:_proper_|
| 2 | gen |   **F**:_feminine_;   **M**:_masculine_;   **C**:_common_|
| 3 | num |   **S**:_singular_;   **P**:_plural_;   **N**:_invariable_|
| 4 | neclass |   **S**:_person_;   **G**:_location_;   **O**:_organization_;   **V**:_other_|
| 5 | nesubclass | _Not used_|
| 6 | degree |   **V**:_evaluative_|

### Part of Speech: `pronoun`
| Position | Atribute | Values |
|:----     |:----     |:----   |
| 0        | category | **P**:_pronoun_ |
| 1 | type |   **D**:_demonstrative_;   **E**:_exclamative_;   **I**:_indefinite_;   **P**:_personal_;   **R**:_relative_;   **T**:_interrogative_|
| 2 | person |   **1**:_1_;   **2**:_2_;   **3**:_3_|
| 3 | gen |   **F**:_feminine_;   **M**:_masculine_;   **C**:_common_|
| 4 | num |   **S**:_singular_;   **P**:_plural_;   **N**:_invariable_|
| 5 | case |   **N**:_nominative_;   **A**:_accusative_;   **D**:_dative_;   **O**:_oblique_|
| 6 | polite |   **P**:_yes_|

### Part of Speech: `adverb`
| Position | Atribute | Values |
|:----     |:----     |:----   |
| 0        | category | **R**:_adverb_ |
| 1 | type |   **N**:_negative_;   **G**:_general_|

### Part of Speech: `adposition`
| Position | Atribute | Values |
|:----     |:----     |:----   |
| 0        | category | **S**:_adposition_ |
| 1 | type |   **P**:_preposition_|

### Part of Speech: `verb`
| Position | Atribute | Values |
|:----     |:----     |:----   |
| 0        | category | **V**:_verb_ |
| 1 | type |   **M**:_main_;   **A**:_auxiliary_;   **S**:_semiauxiliary_|
| 2 | mood |   **I**:_indicative_;   **S**:_subjunctive_;   **M**:_imperative_;   **P**:_participle_;   **G**:_gerund_;   **N**:_infinitive_|
| 3 | tense |   **P**:_present_;   **I**:_imperfect_;   **F**:_future_;   **S**:_past_;   **C**:_conditional_|
| 4 | person |   **1**:_1_;   **2**:_2_;   **3**:_3_|
| 5 | num |   **S**:_singular_;   **P**:_plural_|
| 6 | gen |   **F**:_feminine_;   **M**:_masculine_;   **C**:_common_|

### Part of Speech: `number`
| Position | Atribute | Values |
|:----     |:----     |:----   |
| 0        | category | **Z**:_number_ |
| 1 | type |   **d**:_partitive_;   **m**:_currency_;   **p**:_percentage_;   **u**:_unit_|

### Part of Speech: `date`
| Position | Atribute | Values |
|:----     |:----     |:----   |
| 0        | category | **W**:_date_ |

### Part of Speech: `interjection`
| Position | Atribute | Values |
|:----     |:----     |:----   |
| 0        | category | **I**:_interjection_ |


## Non-positional tags

### Part of Speech: `punctuation`
| Tag  | Attributes |
|:---- |:----       |
| Fd | **pos**:_punctuation_;   **type**:_colon_|
| Fc | **pos**:_punctuation_;   **type**:_comma_|
| Flt | **pos**:_punctuation_;  **type**:_curlybracket_;   **punctenclose**:_close_|
| Fla | **pos**:_punctuation_;  **type**:_curlybracket_;   **punctenclose**:_open_|
| Fs | **pos**:_punctuation_;   **type**:_etc_|
| Fat | **pos**:_punctuation_;  **type**:_exclamationmark_;   **punctenclose**:_close_|
| Faa | **pos**:_punctuation_;  **type**:_exclamationmark_;   **punctenclose**:_open_|
| Fg | **pos**:_punctuation_;   **type**:_hyphen_|
| Fz | **pos**:_punctuation_;   **type**:_other_|
| Fpt | **pos**:_punctuation_;  **type**:_parenthesis_;   **punctenclose**:_close_|
| Fpa | **pos**:_punctuation_;  **type**:_parenthesis_;   **punctenclose**:_open_|
| Ft | **pos**:_punctuation_;   **type**:_percentage_|
| Fp | **pos**:_punctuation_;   **type**:_period_|
| Fit | **pos**:_punctuation_;  **type**:_questionmark_;   **punctenclose**:_close_|
| Fia | **pos**:_punctuation_;  **type**:_questionmark_;   **punctenclose**:_open_|
| Fe | **pos**:_punctuation_;   **type**:_quotation_|
| Frc | **pos**:_punctuation_;  **type**:_quotation_;   **punctenclose**:_close_|
| Fra | **pos**:_punctuation_;  **type**:_quotation_;   **punctenclose**:_open_|
| Fx | **pos**:_punctuation_;   **type**:_semicolon_|
| Fh | **pos**:_punctuation_;   **type**:_slash_|
| Fct | **pos**:_punctuation_;  **type**:_squarebracket_;   **punctenclose**:_close_|
| Fca | **pos**:_punctuation_;  **type**:_squarebracket_;   **punctenclose**:_open_|
