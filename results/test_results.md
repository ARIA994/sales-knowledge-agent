# Test results

Three things were tested separately: whether retrieval finds the right document,
whether the answers are correct, and whether memory works across users.

---

## 1. Retrieval, before any model is involved

16 questions, each run against the vector store alone. The question was embedded,
the top chunks returned, and the source filename checked against the expected one.
No LLM in this test.

Two of the 16 questions have no answer in the documents, so 14 are scoreable.

| Metric | topK 5 |
|---|---|
| Correct document at rank 1 | 12 / 14 |
| Correct document in the returned set | 14 / 14 |

Both rank-1 misses returned the correct document at rank 2, beaten by between
0.004 and 0.02 similarity. This is why the retrieved set is passed to the model
rather than only the top hit.

**The two refusal questions behaved as intended.** "How many customers does
Hirelane have?" scored 0.295 at the top, against 0.643 for a question with a real
answer. A low top score is the signal that nothing relevant exists.

---

## 2. Answers

Same 16 questions, now with the model answering from the retrieved chunks.

| | topK 5 | topK 8 |
|---|---|---|
| Correct answers | 15 / 16 | **16 / 16** |
| Correct refusals | 4 / 4 | 4 / 4 |
| Conflicts handled correctly | 5 / 5 | 5 / 5 |

### The one failure at topK 5

Q14, "What is the minimum company size for Core?", returned "no current minimum is
documented". The answer is 200 employees, stated in a table in `01_pricing.md > Plans`.
That chunk was not in the five retrieved; a different pricing chunk was.

The model answered correctly about what it had been given, said it could not
confirm a number, and told the rep to check with ops before quoting. **The failure
was in retrieval, and the guardrails turned it into a refusal rather than a wrong
number.** Raising topK to 8 fixed it.

### A bug worth recording

During the topK change, the code that groups retrieved chunks by question still
sliced them into groups of five. With eight chunks per question, every question
after the first received a mix of its own chunks and the previous question's.

The agent answered 9 of 16 with some version of "the sources don't contain this",
and invented nothing in any of them. The context was silently wrong and the output
was still safe. The guardrails were doing real work, not decorating the prompt.

---

## 3. Memory

Eight turns, two users alternating, run one at a time so each answer was saved
before the next question.

| Turn | User | Question | Correct |
|---|---|---|---|
| 1 | anna | What does Growth cost per employee? | yes |
| 2 | ben | How long does implementation take? | yes |
| 3 | anna | What about Enterprise? | yes |
| 4 | ben | What about Enterprise? | yes |
| 5 | ben | Why does it sometimes take longer? | yes |
| 6 | anna | And the minimum company size for that one? | yes |
| 7 | anna | What about Dutch payroll? | yes |
| 8 | ben | Can we migrate their data from Recruitee? | yes |

**8 / 8 correct.**

### Turns 3 and 4

The same seven words, asked by two different users, one after the other:

> **anna:** What about Enterprise?
> Enterprise is custom pricing starting from EUR 9.50 per employee per month,
> billed annually, with a 500-employee minimum (01_pricing.md, Plans).

> **ben:** What about Enterprise?
> Enterprise implementation takes 8 to 12 weeks, depending on integrations and
> approval complexity (10_implementation.md, Standard timeline).

Anna had been asking about pricing, Ben about implementation. Neither context
leaked into the other.

### Turn 6

"And the minimum company size for that one?" refers back two turns, and "that one"
is never named. The rewrite step resolved it to Enterprise and the answer was 500
employees. Searching on the raw question would have returned nothing useful.

### Turn 7

Anna had spent three turns on pricing, then jumped to "What about Dutch payroll?".
The rewrite did not carry the pricing context across, and the answer came from the
integrations document.

### Turn 8

The implementation document and the competitor document describe Recruitee migration
slightly differently. The agent gave the fuller version and noted the discrepancy,
unprompted.
