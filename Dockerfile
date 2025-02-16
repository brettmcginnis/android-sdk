FROM ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive
ENV LANG en_US.UTF-8

ENV VERSION_TOOLS "11076708"

ENV ANDROID_HOME "/sdk"
ENV ANDROID_TOOLS "${ANDROID_HOME}/cmdline-tools"
ENV PATH "${PATH}:${ANDROID_TOOLS}"

RUN apt-get update \
		&& apt-get install --no-install-recommends -y \
        apt-utils \
        build-essential \
        bzip2 \
        curl \
        git \
        html2text \
        locales \
        openjdk-21-jdk \
        unzip \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

RUN locale-gen

RUN rm -f /var/lib/dpkg/info/ca-certificates-java.postinst configure

RUN curl -s https://dl.google.com/android/repository/commandlinetools-linux-${VERSION_TOOLS}_latest.zip > /tools.zip && \
    unzip /tools.zip -d ${ANDROID_HOME} && \
    rm -v /tools.zip

RUN mkdir -p ${ANDROID_HOME}/licenses/ && \
    printf "8933bad161af4178b1185d1a37fbf41ea5269c55\\nd56f5187479451eabf01fb78af6dfcb131a6481e\\n24333f8a63b6825ea9c5514f83c2829b004d1fee" > ${ANDROID_HOME}/licenses/android-sdk-license && \
    printf "84831b9409646a918e30573bab4c9c91346d8abd\\n504667f4c0de7af1a06de9f4b1727b84351f2910" > ${ANDROID_HOME}/licenses/android-sdk-preview-license

RUN yes | ${ANDROID_TOOLS}/bin/sdkmanager --sdk_root=${ANDROID_HOME} --licenses

RUN mkdir -p /root/.android && \
    touch /root/.android/repositories.cfg && \
    ${ANDROID_TOOLS}/bin/sdkmanager --sdk_root=${ANDROID_HOME} --update

COPY packages.txt ${ANDROID_HOME}
RUN while read -r package; do PACKAGES="${PACKAGES}${package} "; done < /sdk/packages.txt && \
    ${ANDROID_TOOLS}/bin/sdkmanager --sdk_root=${ANDROID_HOME} ${PACKAGES}

RUN chmod +070 ${ANDROID_HOME}
