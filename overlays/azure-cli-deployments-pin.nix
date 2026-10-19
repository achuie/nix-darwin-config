# azure-cli requires azure-mgmt-resource-deployments==1.0.0b1 (src/azure-cli/setup.py), but nixpkgs
# builds it against whatever version the standalone package carries, which is 1.0.0 as of the current pin,
# 2.0.0 on master. Those releases replaced the msrest `Deployment` model with a dict-backed typespec
# model that serializes `properties` before `location`. That breaks the JSONC splice in
# azure.cli.command_modules.resource.custom.JsonCTemplatePolicy:
#
#     partial_request = json.dumps(modified_data)
#     json_data = partial_request[:-2] + ", template:" + template + r"}}"
#
# which assumes `properties` is the last top-level key. With the newer model the `[:-2]` truncates
# the `location` value instead, and every subscription- or management-group-scoped deployment fails:
#
#     InvalidRequestContent: ... unexpected character was encountered: $. Path 'location'
#
# `what-if` escapes it (custom.py builds ScopedDeploymentWhatIf with location= first), so only
# `az deployment sub create` / `validate` break.
#
# Pin back to the version azure-cli's own metadata asks for. Identical dependency set to 1.0.0.
# Drop this once nixpkgs' azure-cli honors its pin, or azure-cli ships an order-independent splice.

final: prev:

let
  version = "1.0.0b1";
in
{
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (pyfinal: pyprev: {
      azure-mgmt-resource-deployments = pyprev.azure-mgmt-resource-deployments.overridePythonAttrs (_: {
        inherit version;

        src = final.fetchPypi {
          pname = "azure_mgmt_resource_deployments";
          inherit version;
          hash = "sha256-c1m0JliCbn5/8T5tuwxJDpX8yV28oiTSuFz3GtdTXx0=";
        };
      });
    })
  ];
}
