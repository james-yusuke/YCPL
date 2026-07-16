# Project Status

## About This Project

The reason I started building this language was simple.

I wanted to gain a much deeper understanding of LLVM, and I wanted to challenge myself to build a programming language from scratch—something inspired by languages like Rust, Zig, Nim, and Odin.

This project began as a personal hobby driven entirely by curiosity.

---

## Current Status

Since 2026, I've gone through periods of mental instability, which has made development irregular at times.

Because of that, this project has no fixed roadmap or release schedule.
I simply work on it whenever I'm able to.

### Technical Milestone

YCPL has reached a fully self-hosted compiler fixed point. The standard `ycc`
is written in YCPL and reproduces itself through stage2 and stage3 without
calling the C++ compiler. The C++ implementation remains only as the initial
seed and reference compiler, `ycc-bootstrap`.

This milestone does not mean the language is production-ready. YCPL remains an
early-alpha project, and its language, runtime, tooling, and compatibility may
continue to change.

---

## What I Hope This Project Can Be

My goal is not to turn this into a production-ready product or a widely adopted language.

Instead, I hope people will explore the source code, modify it freely, learn from it, and perhaps gain a better understanding of LLVM, compilers, and language design.

More than anything, I hope this project reminds people that building programming languages can simply be fun.

---

## A Personal Note

To be honest, I don't know whether I'll still be around by the time this language is finished.

That's one of the reasons this repository exists in the open.

I'd be happy if you viewed it as the record of one developer building something they genuinely enjoyed creating.

If this project inspires someone to learn, experiment, or even build a language of their own, then it has already achieved something meaningful.
