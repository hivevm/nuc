# The plain-rules sensor misses a sentence end after a link whose text is only a code span

Observed: a sentence that ends in a link whose text is only a code span, such as a link with the
text `` `docs/GLOSSARY.md` `` followed by a full stop, does not end for the sensor. It drops the
code span and the link target, and the token left before the full stop holds no letter or digit.
The sensor skips such a token without ending the sentence, so it merges the sentence with the next
one and reports a long sentence that is not there. The rewrite of `AGENTS.md` met it in the start
section and worded around it.

Where: the sentence splitter of scripts/sensor-plain-rules.sh (the loop over words that skips a
token without a letter or digit), and what scripts/lib/rules.sh leaves of a link and a code span.
