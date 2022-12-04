#
# Copyright 2016-present Pnoker All Rights Reserved
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#     http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

FROM registry.cn-beijing.aliyuncs.com/dc3/alpine-java:corretto-11
MAINTAINER pnoker <pnokers.icloud.com>

ENV JAVA_OPS -server \
             -javaagent:/usr/local/java/lib/aspectjweaver.jar \
             -Xms512m \
             -Xmx2048m \
             -Xss1m \
             -Djava.security.egd=file:/dev/./urandom \
             -XX:MaxDirectMemorySize=256m \
             -XX:+UseCompressedOops \
             -XX:+UseCompressedClassPointers \
             -XX:+SegmentedCodeCache \
             -XX:+PrintCommandLineFlags
ENV GC_LOG   -verbose:gc \
             -XX:+UseG1GC \
             -XX:+ExplicitGCInvokesConcurrent \
             -Xlog:gc*:dc3/logs/center/register/gc/dc3-center-register-gc.log:time,uptime:filecount=20,filesize=20M

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

WORKDIR /dc3-center/dc3-center-register

ADD ./target/dc3-center-register.jar ./

EXPOSE 8100
VOLUME /dc3-center/dc3-center-register/dc3/logs

CMD mkdir -p /dc3-center/dc3-center-register/dc3/logs/center/register/gc \
    && java ${JAVA_OPS}  ${GC_LOG} -jar dc3-center-register.jar
