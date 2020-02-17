# Github Action to Build and Publish a Container Image

![Actions Status](https://github.com/enercity/axn-container-build-publish/workflows/Test/badge.svg)

## This Action Publishes Docker Images to the [GitHub Package Registry](https://github.com/features/package-registry).  

### Background On The GitHub Package Registry (GPR):

From [the docs](https://help.github.com/en/articles/configuring-docker-for-use-with-github-package-registry):

The GitHub Package Registry allows you to develop your code and host your packages in one place.  GitHub uses the README in your repository to generate the package's description, and you can edit it to reflect details about the package or installation process. GitHub adds metadata for each package version that includes links to the author, repository, commit SHA, version tags, and date.

[The docs](https://help.github.com/en/articles/configuring-docker-for-use-with-github-package-registry) also contain relevant such as how to authenticate and naming conventions.  Some noteable items about publishing Docker Images on GPR:

- Docker Images are tied to a repository.  
- All images are named with the following nomenclature:

    docker.pkg.github.com/{OWNER}/{REPOSITORY}/{IMAGE_NAME}:{TAG}
    
`OWNER` and `REPOSITORY` refer to a unique repository on GitHub, such as `enercity/axn-container-build-publish/`.

## Tagging

This Action will tag each image as follows:

```
{Image_Name}:{Tag}
```

Where:
- `Image_Name` is provided by the user as an input.
- `Tag` is provided by the user as an input.

## Usage

### Example Workflow That Uses This Action

```yaml
name: Publish Docker image to GitHub Package Registry
on: push
jobs:
  build:
    runs-on: ubuntu-latest
    steps:

    - name: Copy Repo Files
      uses: actions/checkout@master

     #This Action Emits 2 Variables, IMAGE_SHA_NAME and IMAGE_URL
     #which you can reference in subsequent steps
    - name: Publish Docker Image to GPR
      uses: enercity/axn-container-build-publish@master
      id: docker
      with:
        IMAGE_NAME: 'test-docker-action'
        TAG: 'my-tag-name'
        DOCKERFILE_PATH: './docker/gpu.Dockerfile'
        BUILD_CONTEXT: './docker/'
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

    # This second step is illustrative and shows how to reference the 
    # output variables.  This is completely optional.
    - name: Show outputs of previous step
      run: |
        echo "The pullable address of the Docker Image is: $IMAGE_URL"
        echo "The docker image is hosted at $IMAGES_LINK"
      env:
        IMAGE_URL: ${{ steps.docker.outputs.IMAGE_URL }}
        IMAGES_LINK: ${{ steps.docker.outputs.IMAGES_LINK }}
```

### Mandatory Inputs

1. `IMAGE_NAME` is the name of the image you would like to push
2. `TAG` is the tag of the image you would like to push
3. `DOCKERFILE_PATH`: The full path (including the filename) relative to the root of the repository that contains the Dockerfile that specifies your build.
4. `BUILD_CONTEXT`: The directory for the build context.  See these [docs](https://docs.docker.com/engine/reference/commandline/build/) for more information on the definition of build context.

## Outputs

You can reference the outputs of an action using [expression syntax](https://help.github.com/en/articles/contexts-and-expression-syntax-for-github-actions), as illustrated in the Example Pipeline above.

1. `IMAGE_URL`: This is the docker usable iamge url.
2. `IMAGE_IMAGES_LINKURL`: This is the URL on GitHub where you can view your hosted Docker images.  This will always be located at `https://github.com/{OWNER}/{REPOSITORY}/packages` in reference to the repository where the action was called.

These outputs are merely provided as convenience incase you want to use these values in subsequent steps.
