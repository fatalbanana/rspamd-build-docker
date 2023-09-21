local ci_image = 'nerfd/ci';
local pkg_image = 'nerfd/pkg';

local ALPINE_VERSION = '3.17.0';
local FEDORA_VERSION = '38';
local UBUNTU_VERSION = '22.04';

local docker_defaults = {
  username: {
    from_secret: 'docker_username',
  },
  password: {
    from_secret: 'docker_password',
  },
};

local pipeline_defaults = {
  kind: 'pipeline',
  type: 'docker',
};

local trigger = {
  trigger: {
    branch: [
      'master',
    ],
    event: [
      'push',
      'tag',
      'custom',
    ],
  },
};

local tidyall_pipeline = {
  name: 'tidyall',
  steps: [
    {
      name: 'perl_tidyall_image',
      image: 'plugins/docker',
      settings: {
        dockerfile: 'perl-tidyall/Dockerfile',
        label_schema: [
          'docker.dockerfile=perl-tidyall/Dockerfile',
        ],
        build_args: [
          'ALPINE_VERSION=' + ALPINE_VERSION,
        ],
        repo: ci_image,
        tags: [
          'perl-tidyall',
        ],
      } + docker_defaults,
    },
  ],
} + trigger + pipeline_defaults;

local platform(arch) = {
  platform: {
    os: 'linux',
    arch: arch,
  },
};

local base_image_pipeline(arch) = {
  name: 'base_image_' + arch,
  steps: [
    {
      name: 'base_image',
      image: 'plugins/docker',
      settings: {
        dockerfile: 'ubuntu-gcc/Dockerfile',
        label_schema: [
          'docker.dockerfile=ubuntu-gcc/Dockerfile',
        ],
        build_args: [
          'UBUNTU_VERSION=' + UBUNTU_VERSION,
        ],
        repo: ci_image,
        tags: [
          'ubuntu-gcc-' + arch,
        ],
      } + docker_defaults,
    },
  ],
} + platform(arch) + pipeline_defaults;

local test_image_pipeline(arch) = {
  depends_on: [
    'multiarch_base_image',
  ],
  name: 'test_image_' + arch,
  steps: [
    {
      name: 'test_image',
      image: 'plugins/docker',
      settings: {
        dockerfile: 'ubuntu-test/Dockerfile',
        label_schema: [
          'docker.dockerfile=ubuntu-test/Dockerfile',
        ],
        repo: ci_image,
        tags: [
          'ubuntu-test-' + arch,
        ],
      } + docker_defaults,
    },
  ],
} + platform(arch) + pipeline_defaults;

local build_the_rest_pipeline(arch) = {
  depends_on: [
    'multiarch_test_image',
  ],
  name: 'default-' + arch,
  platform: {
    os: 'linux',
    arch: arch,
  },
  steps: [
    {
      name: 'build_image',
      image: 'plugins/docker',
      settings: {
        dockerfile: 'ubuntu-build/Dockerfile',
        label_schema: [
          'docker.dockerfile=ubuntu-build/Dockerfile',
        ],
        repo: ci_image,
        tags: [
          'ubuntu-build-' + arch,
        ],
      } + docker_defaults,
    },
    {
      name: 'func_test_image',
      image: 'plugins/docker',
      settings: {
        dockerfile: 'ubuntu-test-func/Dockerfile',
        label_schema: [
          'docker.dockerfile=ubuntu-test-func/Dockerfile',
        ],
        repo: ci_image,
        tags: [
          'ubuntu-test-func-' + arch,
        ],
      } + docker_defaults,
    },
    {
      name: 'fedora_build_image',
      image: 'plugins/docker',
      settings: {
        dockerfile: 'fedora-build/Dockerfile',
        label_schema: [
          'docker.dockerfile=fedora-build/Dockerfile',
        ],
        build_args: [
          'FEDORA_VERSION=' + FEDORA_VERSION,
        ],
        repo: ci_image,
        tags: [
          'fedora-build-' + arch,
        ],
      } + docker_defaults,
    },
    {
      name: 'fedora_test_image',
      image: 'plugins/docker',
      settings: {
        dockerfile: 'fedora-test/Dockerfile',
        label_schema: [
          'docker.dockerfile=fedora-test/Dockerfile',
        ],
        build_args: [
          'FEDORA_VERSION=' + FEDORA_VERSION,
        ],
        repo: ci_image,
        tags: [
          'fedora-test-' + arch,
        ],
      } + docker_defaults,
      depends_on: [
        'fedora_build_image',
      ],
    },
    {
      name: 'centos8_pkg_image',
      image: 'plugins/docker',
      settings: {
        dockerfile: 'centos-8/Dockerfile',
        label_schema: [
          'docker.dockerfile=centos-8/Dockerfile',
        ],
        repo: pkg_image,
        tags: [
          'centos-8-' + arch,
        ],
      } + docker_defaults,
    },
    {
      name: 'centos9_pkg_image',
      image: 'plugins/docker',
      settings: {
        dockerfile: 'centos-9/Dockerfile',
        label_schema: [
          'docker.dockerfile=centos-9/Dockerfile',
        ],
        repo: pkg_image,
        tags: [
          'centos-9-' + arch,
        ],
      } + docker_defaults,
    },
    {
      name: 'centos7_pkg_image',
      image: 'plugins/docker',
      settings: {
        dockerfile: 'centos-7/Dockerfile',
        label_schema: [
          'docker.dockerfile=centos-7/Dockerfile',
        ],
        repo: pkg_image,
        tags: [
          'centos-7-' + arch,
        ],
      } + docker_defaults,
    },
    {
      name: 'ubuntu_jammy_pkg_image',
      image: 'plugins/docker',
      settings: {
        dockerfile: 'ubuntu-jammy/Dockerfile',
        label_schema: [
          'docker.dockerfile=ubuntu-jammy/Dockerfile',
        ],
        repo: pkg_image,
        tags: [
          'ubuntu-jammy-' + arch,
        ],
      } + docker_defaults,
    },
    {
      name: 'ubuntu_focal_pkg_image',
      image: 'plugins/docker',
      settings: {
        dockerfile: 'ubuntu-focal/Dockerfile',
        label_schema: [
          'docker.dockerfile=ubuntu-focal/Dockerfile',
        ],
        repo: pkg_image,
        tags: [
          'ubuntu-focal-' + arch,
        ],
      } + docker_defaults,
    },
    {
      name: 'debian_bullseye_pkg_image',
      image: 'plugins/docker',
      settings: {
        dockerfile: 'debian-bullseye/Dockerfile',
        label_schema: [
          'docker.dockerfile=debian-bullseye/Dockerfile',
        ],
        repo: pkg_image,
        tags: [
          'debian-bullseye-' + arch,
        ],
      } + docker_defaults,
    },
    {
      name: 'debian_bookworm_pkg_image',
      image: 'plugins/docker',
      settings: {
        dockerfile: 'debian-bookworm/Dockerfile',
        label_schema: [
          'docker.dockerfile=debian-bookworm/Dockerfile',
        ],
        repo: pkg_image,
        tags: [
          'debian-bookworm-' + arch,
        ],
      } + docker_defaults,
    },
  ],
} + trigger + pipeline_defaults;

local multiarch_step(step_name, image_name, image_tag) = {
  name: step_name,
  image: 'plugins/manifest',
  settings: {
    target: std.format('%s:%s', [image_name, image_tag]),
    template: std.format('%s:%s-ARCH', [image_name, image_tag]),
    platforms: [
      'linux/amd64',
      'linux/arm64',
    ],
  } + docker_defaults,
};

local final_multiarch_steps = {
  steps: [
    multiarch_step('build_image', ci_image, 'ubuntu-build'),
    multiarch_step('ci_ubuntu_test_func', ci_image, 'ubuntu-test-func'),
    multiarch_step('ci_fedora_build', ci_image, 'fedora-build'),
    multiarch_step('ci_fedora_test', ci_image, 'fedora-test'),
    multiarch_step('pkg_centos7', pkg_image, 'centos-7'),
    multiarch_step('pkg_centos8', pkg_image, 'centos-8'),
    multiarch_step('pkg_centos9', pkg_image, 'centos-9'),
    multiarch_step('pkg_ubuntu2004', pkg_image, 'ubuntu-focal'),
    multiarch_step('pkg_ubuntu2204', pkg_image, 'ubuntu-jammy'),
    multiarch_step('pkg_debian11', pkg_image, 'debian-bullseye'),
    multiarch_step('pkg_debian12', pkg_image, 'debian-bookworm'),
  ],
};

local multiarchify_the_rest = {
  name: 'multiarchify_the_rest',
  depends_on: [
    'default-amd64',
    'default-arm64',
  ],
} + final_multiarch_steps + pipeline_defaults;

local multiarch_base_image = {
  name: 'multiarch_base_image',
  depends_on: [
    'base_image_amd64',
    'base_image_arm64',
  ],
  steps: [
    multiarch_step('multiarch_base_image', ci_image, 'ubuntu-gcc'),
  ],
} + pipeline_defaults;

local multiarch_build_image = {
  name: 'multiarch_build_image',
  depends_on: [
    'build_image_amd64',
    'build_image_arm64',
  ],
  steps: [
    multiarch_step('multiarch_build_image', ci_image, 'ubuntu-build'),
  ],
} + pipeline_defaults;

local multiarch_test_image = {
  name: 'multiarch_test_image',
  depends_on: [
    'test_image_amd64',
    'test_image_arm64',
  ],
  steps: [
    multiarch_step('multiarch_test_image', ci_image, 'ubuntu-test'),
  ],
} + pipeline_defaults;

local signature_placeholder = {
  kind: 'signature',
  hmac: '0000000000000000000000000000000000000000000000000000000000000000',
};

[
  tidyall_pipeline,
  base_image_pipeline('amd64'),
  base_image_pipeline('arm64'),
  multiarch_base_image,
  test_image_pipeline('amd64'),
  test_image_pipeline('arm64'),
  multiarch_test_image,
  build_the_rest_pipeline('amd64'),
  build_the_rest_pipeline('arm64'),
  multiarchify_the_rest,
  signature_placeholder,
]
