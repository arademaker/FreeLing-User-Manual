
# Depdendency Parsing {#dependency-parsing}

FreeLing includes several dependency parsers, build using different technologies.

* [Rule-based Dependency Parser](dep_txala.md)
  Faster and simpler. Lower accuracy, higher speed. Customizable behaviour altering the parsing rules.
* [Statistical Dependency Parser](dep_treeler.md) 
  Machine-learning parser. Slower but mor accurate than the rule-base.
* [Neural Dependency Parser](dep_lstm.md) 
  Neural network based tagger. Faster and more accurate than the Statistical parser. Slower than the rule-based.
