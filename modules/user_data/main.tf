locals {
  runner_labels = join(",", var.config.runner_labels)

  ssm_match = regex("^arn:aws:ssm:(.*):.*:parameter(.*)$", var.config.ssm_parameter_arn)

  ssm_region         = local.ssm_match[0]
  ssm_parameter_name = local.ssm_match[1]

  user_data = templatefile(
    "${path.module}/cloud-init.yaml", {
      SSM_REGION         = local.ssm_region
      SSM_PARAMETER_NAME = local.ssm_parameter_name

      PACKAGES = var.config.cloud_init_packages
      RUNCMDS  = var.config.cloud_init_runcmds
      OTHER    = var.config.cloud_init_other

      GITHUB_URL = var.config.github_url
      GITHUB_ORGANISATION_NAME = (
        length(var.config.github_organisation_name) > 0
        ? var.config.github_organisation_name
        : split("/",
          regex(
            #https://www.rfc-editor.org/rfc/rfc3986#appendix-B
            "^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\\?([^#]*))?(#(.*))?",
          var.config.github_url)[4]
        )[1]
      )

      ARG_NAME        = length(var.config.runner_name) > 0 ? "--name '${var.config.runner_name}'" : ""
      ARG_RUNNERGROUP = length(var.config.runner_group) > 0 ? "--runnergroup '${var.config.runner_group}'" : ""
      ARG_LABELS      = length(local.runner_labels) > 0 ? "--labels '${local.runner_labels}'" : ""
  })
}

/*
./actions-runner/config.sh --help

Commands:
 ./config.sh         Configures the runner
 ./config.sh remove  Unconfigures the runner
 ./run.sh            Runs the runner interactively. Does not require any options.

Options:
 --help     Prints the help for each command
 --version  Prints the runner version
 --commit   Prints the runner commit
 --check    Check the runner's network connectivity with GitHub server

Config Options:
 --unattended           Disable interactive prompts for missing arguments. Defaults will be used for missing options
 --url string           Repository to add the runner to. Required if unattended
 --token string         Registration token. Required if unattended
 --name string          Name of the runner to configure (default ip-10-1-226-36)
 --runnergroup string   Name of the runner group to add this runner to (defaults to the default runner group)
 --labels string        Extra labels in addition to the default: 'self-hosted,Linux,X64'
 --work string          Relative runner work directory (default _work)
 --replace              Replace any existing runner with the same name (default false)
 --pat                  GitHub personal access token with repo scope. Used for checking network connectivity when executing `./run.sh --check`
 --disableupdate        Disable self-hosted runner automatic update to the latest released version`
 --ephemeral            Configure the runner to only take one job and then let the service un-configure the runner after the job finishes (default false)

Examples:
 Check GitHub server network connectivity:
  ./run.sh --check --url <url> --pat <pat>
 Configure a runner non-interactively:
  ./config.sh --unattended --url <url> --token <token>
 Configure a runner non-interactively, replacing any existing runner with the same name:
  ./config.sh --unattended --url <url> --token <token> --replace [--name <name>]
 Configure a runner non-interactively with three extra labels:
  ./config.sh --unattended --url <url> --token <token> --labels L1,L2,L3
*/
