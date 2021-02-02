"Bazel helper rules"

load("@npm//@bazel/typescript:index.bzl", "ts_project")
load("@build_bazel_rules_nodejs//:index.bzl", "js_library")
load("@npm//jest:index.bzl", "jest", _jest_test = "jest_test")

def ts_compile(name, srcs, deps, package_name = None, package_json = None, esm = True):
    """Compile TS with prefilled args.

    Args:
        name: target name
        srcs: src files
        deps: deps
        package_name: name from package.json
        package_json: If a package.json is here provide it
        esm: If an e
    """
    deps = deps + ["@npm//tslib"]

    ts_project(
        name = "%s-base" % name,
        srcs = srcs,
        declaration = True,
        tsconfig = "tsconfig.json",
        extends = "//:tsconfig.json",
        deps = deps,
    )
    if esm:
        ts_project(
            name = "%s-esm" % name,
            srcs = srcs,
            declaration = True,
            extends = "//:tsconfig.json",
            out_dir = "esm",
            tsconfig = "//:tsconfig.esm.json",
            deps = deps,
        )

    native.filegroup(
        name = "types",
        srcs = [":%s-base" % name],
        output_group = "types",
        visibility = ["//visibility:public"],
    )

    js_library(
        name = name,
        package_name = package_name,
        srcs = ["package.json"] if package_json else [],
        deps = [":%s-base" % name] + ([":%s-esm" % name] if esm else []),
        visibility = ["//visibility:public"],
    )

def jest_test(
        name,
        srcs,
        deps = [],
        size = "medium",
        jest_config = "//:jest.config.js",
        snapshots = [],
        flaky = False,
        additional_args = [],
        **kwargs):
    """A macro around the autogenerated jest_test rule.

    Args:
        name: target name
        srcs: list of tests, srcs & snapshot files
        deps: npm deps
        size: test size
        snapshots: snapshot files
        jest_config: jest.config.js file, default to the root one
        flaky: Whether this test is flaky
        additional_args: Additional CLI arguments
        **kwargs: the rest
    """

    templated_args = [
        "--config",
        "$(rootpath %s)" % jest_config,
        "--no-cache",
        "--no-watchman",
        "--ci",
        "--runInBand",
        "--colors",
        
    ] + additional_args

    for src in srcs:
        templated_args.extend(["--runTestsByPath", "$(rootpath %s)" % src])

    data = [jest_config] + srcs + snapshots + deps + [
        "@npm//@types/node",
        "@npm//@types/jest",
        "@npm//tslib",
        # "@npm//ts-jest",
        # "@npm//@jest/transform",
        # "//:tsconfig.json",
        "//tools:jest-reporter.js",
    ]

    _jest_test(
        name = name,
        data = data,
        templated_args = templated_args,
        size = size,
        flaky = flaky,
        **kwargs
    )

    jest(
        name = "%s.update" % name,
        data = data,
        templated_args = templated_args + ["-u"],
        **kwargs
    )