#!/usr/bin/groovy

def label = "packer-linux-${UUID.randomUUID().toString()}"

podTemplate(label: label,
  envVars: [
    envVar(key: 'PACKER_VERSION', value: '1.2.0')
  ],
  containers: [
    containerTemplate(name: 'jnlp',
                      image: 'jenkins/jnlp-slave:3.16-1-alpine',
                      args: '${computer.jnlpmac} ${computer.name}',
                      workingDir: '/home/jenkins',
                      resourceRequestCpu: '200m',
                      resourceLimitCpu: '300m',
                      resourceRequestMemory: '256Mi',
                      resourceLimitMemory: '512Mi',
                      privileged: true),
    containerTemplate(name: 'docker',
                      image: 'docker:1.12.6',
                      command: 'cat',
                      ttyEnabled: true),
    containerTemplate(name: 'centos',
                      image: 'centos:centos7',
                      command: 'cat',
                      ttyEnabled: true,
                      envVars: [
                        secretEnvVar(key: 'ARM_CLIENT_ID', secretName: 'arm-client-id', secretKey: 'password'),
                        secretEnvVar(key: 'ARM_CLIENT_SECRET', secretName: 'arm-client-secret', secretKey: 'password'),
                        secretEnvVar(key: 'ARM_SUBSCRIPTION_ID', secretName: 'arm-subscription-id', secretKey: 'password'),
                        secretEnvVar(key: 'ARM_OBJECT_ID', secretName: 'arm-object-id', secretKey: 'password'),
                        secretEnvVar(key: 'ARM_MANAGED_IMAGE_NAME', secretName: 'arm-managed-image-name', secretKey: 'password'),
                        secretEnvVar(key: 'ARM_MANAGED_IMAGE_RESOURCE_GROUP', secretName: 'arm-managed-image-resource-group', secretKey: 'password'),
                        secretEnvVar(key: 'ARM_BUILD_RESOURCE_GROUP_NAME', secretName: 'arm-build-resource-group-name', secretKey: 'password'),
                        secretEnvVar(key: 'ARM_VIRTUAL_NETWORK_NAME', secretName: 'arm-virtual-network-name', secretKey: 'password'),
                        secretEnvVar(key: 'ARM_VIRTUAL_NETWORK_SUBNET_NAME', secretName: 'arm-virtual-network-subnet-name', secretKey: 'password'),
                        secretEnvVar(key: 'ARM_VIRTUAL_NETWORK_RESOURCE_NAME', secretName: 'arm-virtual-network-resource-name', secretKey: 'password')
                      ])
  ],
  volumes:[
    hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock')
  ]) {

  node (label) {
    stage('Run shell') {

      git 'https://github.com/govcloud/packer-windows.git'

      container('centos') {

        // Install deps
        sh 'yum install -y \
              unzip \
              tar \
              gzip \
              wget && \
            yum clean all && rm -rf /var/cache/yum/*'

        // Install packer
        sh 'curl -L -o packer_${PACKER_VERSION}_linux_amd64.zip https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip && \
            curl -L -o packer_${PACKER_VERSION}_SHA256SUMS https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_SHA256SUMS && \
            sed -i "/packer_${PACKER_VERSION}_linux_amd64.zip/!d" packer_${PACKER_VERSION}_SHA256SUMS && \
            sha256sum -c packer_${PACKER_VERSION}_SHA256SUMS && \
            unzip packer_${PACKER_VERSION}_linux_amd64.zip -d /bin && \
            rm -f packer_${PACKER_VERSION}_linux_amd64.zip'

        // Image build
        sh '/bin/packer build \
              -force \
              -var-file=windows10.json \
              windows_managed.json'
      }
    }

  }
}
