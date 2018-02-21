#!/usr/bin/groovy

// load pipeline functions
// Requires pipeline-github-lib plugin to load library from github

@Library('github.com/sylus/jenkins-pipeline@dev')

def pipeline = new io.estrado.Pipeline()
def label = "packer-linux-${UUID.randomUUID().toString()}"

podTemplate(
  label: label,
  envVars: [
    envVar(key: 'PACKER_VERSION', value: '1.2.0'),
    secretEnvVar(key: 'ARM_CLIENT_ID', secretName: 'arm-client-id', secretKey: 'password'),
    secretEnvVar(key: 'ARM_CLIENT_SECRET', secretName: 'arm-client-secret', secretKey: 'password'),
    secretEnvVar(key: 'ARM_SUBSCRIPTION_ID', secretName: 'arm-subscription-id', secretKey: 'password'),
    secretEnvVar(key: 'ARM_OBJECT_ID', secretName: 'arm-object-id', secretKey: 'password'),
    secretEnvVar(key: 'ARM_BUILD_RESOURCE_GROUP_NAME', secretName: 'arm-build-resource-group-name', secretKey: 'password'),

    secretEnvVar(key: 'ARM_VIRTUAL_NETWORK_NAME', secretName: 'arm-virtual-network-name', secretKey: 'password'),
    secretEnvVar(key: 'ARM_VIRTUAL_NETWORK_SUBNET_NAME', secretName: 'arm-virtual-network-subnet-name', secretKey: 'password'),
    secretEnvVar(key: 'ARM_VIRTUAL_NETWORK_RESOURCE_NAME', secretName: 'arm-virtual-network-resource-name', secretKey: 'password'),

    // Managed Image
    // envVar(key: 'ARM_MANAGED_IMAGE_NAME', value: label),
    // secretEnvVar(key: 'ARM_MANAGED_IMAGE_RESOURCE_GROUP', secretName: 'arm-managed-image-resource-group', secretKey: 'password'),

    // VHD
    secretEnvVar(key: 'ARM_VHD_CAPTURE_CONTAINER_NAME', secretName: 'arm-capture-container-name', secretKey: 'password'),
    secretEnvVar(key: 'ARM_VHD_CAPTURE_NAME_PREFIX', secretName: 'arm-capture-name-prefix', secretKey: 'password'),
    secretEnvVar(key: 'ARM_VHD_RESOURCE_GROUP_NAME', secretName: 'arm-resource-group-name', secretKey: 'password'),
    secretEnvVar(key: 'ARM_VHD_STORAGE_ACCOUNT', secretName: 'arm-storage-account', secretKey: 'password')
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
                      privileged: false),
    containerTemplate(name: 'docker',
                      image: 'docker:1.12.6',
                      command: 'cat',
                      ttyEnabled: true),
    containerTemplate(name: 'centos',
                      image: 'centos:centos7',
                      command: 'cat',
                      ttyEnabled: true,
                      privileged: false,
                      ports: [portMapping(name: 'winrm', containerPort: 5986, hostPort: 5986)])
  ],
  volumes:[
    hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock')
  ]) {

  node (label) {
    stage('Create immutable image') {

      checkout scm

      def pwd = pwd()
      def inputFile = readFile('Jenkinsfile.json')
      def config = new groovy.json.JsonSlurperClassic().parseText(inputFile)
      println "pipeline config ==> ${config}"

      // continue only if pipeline enabled
      if (!config.pipeline.enabled) {
          println "pipeline disabled"
          return
      }

      // set additional git envvars for image tagging
      pipeline.gitEnvVars()

      // If pipeline debugging enabled
      if (config.pipeline.debug) {
        println "DEBUG ENABLED"
        sh "env | sort"
      }

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
        sh 'PACKER_LOG=1 /bin/packer build \
              -force \
              -var-file=windows10.json \
              windows.json'
      }
    }

  }
}
