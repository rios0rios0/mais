# Project-level ProGuard keep rules, appended by the pipelines dead-code check
# (`global/scripts/languages/java/proguard/run.sh`) to its generated config.
#
# ProGuard analyses BYTECODE, not source. Everything kept here is a construct
# that the source demonstrably uses but that leaves no read in the bytecode for
# a call-graph walk to find, so `-printusage` reports it as unreachable. These
# are analyser blind spots, not dead code; genuinely dead members are deleted
# instead (see the `Colorize.setColor(String, Params)` overload removed
# alongside this file).
#
# Each entry names the exact member it exempts. Nothing here is a wildcard over
# a modifier or a package, so a NEW unused member anywhere in the project is
# still reported.

# 2026-08-26 -- Compile-time constants (JLS 13.1 / 4.12.4).
#
# A `private static final` field initialised with a constant expression is
# folded into every use site by javac and carries a `ConstantValue` attribute;
# the field itself is never read with `getstatic`. Verified on the compiled
# classes with `javap -p -c`: `Commands.executeCommandRoot` loads
# `ldc "echo <value> | sudo -S"` as one already-concatenated literal, and no
# `getstatic` for any of the three fields exists anywhere in `target/classes`.
#
# Deleting them would delete the values the program runs on, and dropping
# `final` to defeat the folding would degrade correct source for a tool's
# benefit. Keeping them is the accurate answer.
-keepclassmembers class com.rios0rios0.engine.SecurityAgent {
    private static final java.lang.String SERVICE_NAME;
    private static final int CONNECTION_TIMEOUT;
}

# Note: `Commands.SUDO_PASSWD` being a hard-coded credential is a real and
# separate finding (SonarCloud `java:S2068`), untouched by this rule -- this
# keeps ProGuard from misreporting the field as *unreachable*, which it is not.
-keepclassmembers class com.rios0rios0.utils.Commands {
    private static final java.lang.String SUDO_PASSWD;
}

# 2026-08-26 -- Serialization contract.
#
# `serialVersionUID` is read reflectively by `java.io.ObjectStreamClass` during
# (de)serialization, so no bytecode ever references it and a static call graph
# cannot see the use. Removing it would silently change the stream-unique
# identifier of every `Serializable` class and break compatibility with reports
# already exchanged between agents over RMI. This is ProGuard's own documented
# rule for serialization, narrowed to the exact field signature.
-keepclassmembers class * implements java.io.Serializable {
    private static final long serialVersionUID;
}
