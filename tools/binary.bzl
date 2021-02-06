def binary_impl(ctx):

    ctx.actions.expand_template(
        template = ctx.file._binary,
        output = ctx.outputs.run,
        substitutions = {
        },
        is_executable = True,
    )

    return DefaultInfo(
        executable = ctx.outputs.run,
        # files = depset([ctx.outputs.apptar]),
        # runfiles = ctx.runfiles(files = [ctx.outputs.apptar]),
    )

binary = rule(
    implementation = binary_impl,
    executable = True,
    attrs = { 
        "_node_binary": attr.label(
            allow_single_file = True,
            default = Label("@nodejs//:node"),
        ),
        "_binary": attr.label(
            allow_single_file = True,
            default = Label("//tools:binary"),
        ),
    },
    outputs = {
        "run": "%{name}",
    },
)
