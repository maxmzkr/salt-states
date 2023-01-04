import fnmatch
import io
import logging
import re
import tarfile
import zipfile

try:
    import requests

    HAS_REQUESTS = True
except ImportError:
    HAS_REQUESTS = False

log = logging.getLogger(__name__)


__virtualname__ = "gh"


def __virtual__():
    """
    Only load gh if requests is available
    """
    if HAS_REQUESTS:
        return __virtualname__
    else:
        return False, "The wigh module cannot be loaded: requests package unavailable."


def find_md_links(md):
    """Returns dict of links in markdown:
    'regular': [foo](some.url)
    'footnotes': [foo][3]

    [3]: some.url
    """
    # https://stackoverflow.com/a/30738268/2755116

    INLINE_LINK_RE = re.compile(r"\[([^\]]+)\]\(([^)]+)\)")
    FOOTNOTE_LINK_TEXT_RE = re.compile(r"\[([^\]]+)\]\[(\d+)\]")
    FOOTNOTE_LINK_URL_RE = re.compile(r"\[(\d+)\]:\s+(\S+)")

    links = list(INLINE_LINK_RE.findall(md))
    footnote_links = dict(FOOTNOTE_LINK_TEXT_RE.findall(md))
    footnote_urls = dict(FOOTNOTE_LINK_URL_RE.findall(md))

    footnotes_linking = []

    for key in footnote_links.keys():
        footnotes_linking.append(
            (footnote_links[key], footnote_urls[footnote_links[key]])
        )

    return {"regular": links, "footnotes": footnotes_linking}


def archive_binary(
    name,
    repo,
    file_name=None,
    pattern=None,
    api_key=None,
    group=None,
    user=None,
    mode=None,
):
    ret = {
        "name": name,
        "changes": {},
        "result": False,
        "comment": "",
    }

    if __salt__["file.file_exists"](name):
        ret["result"] = True
        ret["comment"] = "binary already exists"
        return ret

    if __opts__["test"] == True:
        ret["comment"] = f"The state of {name} will be changed"
        ret["result"] = None

        return ret

    headers = {}
    if api_key:
        headers["Authorization"] = "token {}".format(api_key)
    list_url = f"https://api.github.com/repos/{repo}/releases/latest"
    response = requests.get(list_url, headers=headers)
    if not response.ok:
        ret["comment"] = f"Error getting latest release: {response.content}"
        return ret
    j = response.json()
    assets = j["assets"]
    for asset in assets:
        if not pattern or fnmatch.fnmatch(asset["name"], pattern):
            asset_url = asset["browser_download_url"]
            response = requests.get(asset_url, headers=headers)
            if not response.ok:
                ret["comment"] = f"Error getting asset: {response.content}"
                return ret
            if asset["name"].endswith(".zip"):
                with zipfile.ZipFile(io.BytesIO(response.content)) as zf:
                    for info in zf.infolist():
                        if not file_name or info.filename == file_name:
                            with open(name, "wb") as f:
                                f.write(zf.read(info.filename))
            elif asset["name"].endswith(".tar.gz"):
                with tarfile.open(
                    fileobj=io.BytesIO(response.content), mode="r:gz"
                ) as tar:
                    for info in tar:
                        if not file_name or info.name == file_name:
                            with open(name, "wb") as f:
                                f.write(tar.extractfile(info.name).read())
            else:
                ret["comment"] = f"The asset has unknown type: {asset['name']}"
                ret["result"] = False
                return ret
            ret["result"] = True
            ret["comment"] = "binary downloaded"
            ret["changes"] = {
                "old": None,
                "new": name,
            }
            if user or group:
                __salt__["file.chown"](name, user, group)
            if mode:
                __salt__["file.set_mode"](name, mode)

            return ret

    return ret


def binary(name, repo, pattern=None, api_key=None, group=None, user=None, mode=None):
    ret = {
        "name": name,
        "changes": {},
        "result": False,
        "comment": "",
    }

    if __salt__["file.file_exists"](name):
        ret["result"] = True
        ret["comment"] = "binary already exists"
        return ret

    if __opts__["test"] == True:
        ret["comment"] = f"The state of {name} will be changed"
        ret["result"] = None

        return ret

    headers = {}
    if api_key:
        headers["Authorization"] = "token {}".format(api_key)
    list_url = f"https://api.github.com/repos/{repo}/releases/latest"
    response = requests.get(list_url, headers=headers)
    if not response.ok:
        ret["comment"] = f"Error getting latest release: {response.content}"
        return ret
    j = response.json()
    assets = j["assets"]
    for asset in assets:
        if not pattern or fnmatch.fnmatch(asset["name"], pattern):
            asset_url = asset["browser_download_url"]
            response = requests.get(asset_url, headers=headers)
            if not response.ok:
                ret["comment"] = f"Error getting asset: {response.content}"
                return ret
            with open(name, "wb") as f:
                f.write(response.content)
            ret["result"] = True
            ret["comment"] = "binary downloaded"
            ret["changes"] = {
                "old": None,
                "new": name,
            }
            if user or group:
                __salt__["file.chown"](name, user, group)
            if mode:
                __salt__["file.set_mode"](name, mode)

            return ret

    return ret


def _proxy(
    func,
    repo,
    pattern,
    api_key,
    asset_key,
    args,
    kwargs,
    version=None,
    link_source=None,
):
    name, *_ = args
    ret = {
        "name": name,
        "changes": {},
        "result": False,
        "comment": "",
    }

    headers = {}
    headers["Authorization"] = "token {}".format(api_key)

    if version is None:
        version = "latest"

    list_url = f"https://api.github.com/repos/{repo}/releases/{version}"
    response = requests.get(list_url, headers=headers)

    if not response.ok:
        ret["comment"] = f"Error getting latest release: {response.content}"
        return ret

    j = response.json()
    if link_source is None:
        for asset in j["assets"]:
            if fnmatch.fnmatch(asset["name"], pattern):
                asset_url = asset["browser_download_url"]
                break
        else:
            ret["comment"] = f"Asset {pattern} not found"
            return ret
    elif link_source == "body":
        for link in find_md_links(j["body"])["regular"]:
            if fnmatch.fnmatch(link[0], pattern):
                asset_url = link[1]
                break
        else:
            ret["comment"] = f"Asset {pattern} not found"
            return ret

    kwargs[asset_key] = asset_url
    return func(*args, **kwargs)


def file_managed(
    name,
    repo,
    pattern,
    api_key,
    link_source=None,
    **kwargs,
):
    return _proxy(
        __states__["file.managed"],
        repo,
        pattern,
        api_key,
        "source",
        (name,),
        kwargs,
        link_source=link_source,
    )


def archive_extracted(
    name,
    repo,
    pattern,
    api_key,
    link_source=None,
    **kwargs,
):
    return _proxy(
        __states__["archive.extracted"],
        repo,
        pattern,
        api_key,
        "source",
        (name,),
        kwargs,
        link_source=link_source,
    )


def pkg_installed(
    name,
    api_key=None,
    sources=None,
    version=None,
    refresh=None,
    fromrepo=None,
    skip_verify=False,
    skip_suggestions=False,
    pkgs=None,
    allow_updates=False,
    pkg_verify=False,
    normalize=True,
    ignore_epoch=None,
    reinstall=False,
    update_holds=False,
    **kwargs,
):
    ret = {
        "name": name,
        "changes": {},
        "result": False,
        "comment": "",
    }

    headers = {}
    if api_key:
        headers["Authorization"] = "token {}".format(api_key)

    nested_sources = None
    if sources != None:
        for source in sources:
            for source_name, source_params in source.items():
                list_url = f'https://api.github.com/repos/{source_params["repo"]}/releases/latest'
                response = requests.get(list_url, headers=headers)
                if not response.ok:
                    ret["comment"] = f"Error getting latest release: {response.content}"
                    return ret
                j = response.json()
                pattern = source_params["pattern"]
                for asset in j["assets"]:
                    if not pattern or fnmatch.fnmatch(asset["name"], pattern):
                        asset_url = asset["browser_download_url"]
                        if nested_sources is None:
                            nested_sources = []
                        nested_sources.append({source_name: asset_url})

    if not nested_sources:
        ret["comment"] = "No sources found"
        return ret

    return __states__["pkg.installed"](
        name,
        version=version,
        refresh=refresh,
        fromrepo=fromrepo,
        skip_verify=skip_verify,
        skip_suggestions=skip_suggestions,
        pkgs=pkgs,
        allow_updates=allow_updates,
        pkg_verify=pkg_verify,
        normalize=normalize,
        ignore_epoch=ignore_epoch,
        reinstall=reinstall,
        update_holds=update_holds,
        sources=nested_sources,
        **kwargs,
    )
