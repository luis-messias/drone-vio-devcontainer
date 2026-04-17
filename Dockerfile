FROM nvcr.io/nvidia/cuda:12.8.1-cudnn-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=compute,utility

# ROS 2 Humble
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        locales \
        software-properties-common \
        curl \
    && locale-gen en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
    && curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu \
    $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        wget \
        ca-certificates \
        python3-colcon-common-extensions \
        python3-rosdep \
        build-essential \
        ros-humble-ros-base \
        ros-dev-tools \
        ros-humble-rqt-graph \
        libeigen3-dev \
        libceres-dev \
        libgoogle-glog-dev \
        libgflags-dev \
        libatlas-base-dev \
        libsuitesparse-dev \
        libopencv-dev \
        libopencv-contrib-dev \
        libboost-dev \
        libboost-system-dev \
        libboost-filesystem-dev \
        libboost-thread-dev \
        libboost-date-time-dev \
        python3-matplotlib \
        python3-numpy \
        python3-scipy \
        ros-humble-cv-bridge \
        ros-humble-image-transport \
        ros-humble-tf2-geometry-msgs \
        ros-humble-tf-transformations \
    && rm -rf /var/lib/apt/lists/*

# PX4 messages
WORKDIR /opt/px4_msgs_ws
RUN git clone --depth 1 --branch release/1.16 https://github.com/PX4/px4_msgs.git src/px4_msgs
RUN rosdep init 2>/dev/null || true \
    && rosdep update \
    && rosdep install --from-paths src --ignore-src --rosdistro humble -y
RUN bash -c "source /opt/ros/humble/setup.bash && colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release"

# ROS 2 workspace
RUN mkdir -p /workspace/src
RUN echo "source /opt/ros/humble/setup.bash" >> /root/.bashrc \
    && echo "source /opt/px4_msgs_ws/install/setup.bash" >> /root/.bashrc \
    && echo "[ -f /workspace/install/setup.bash ] && source /workspace/install/setup.bash" >> /root/.bashrc

# Start bash
WORKDIR /workspace
CMD ["/bin/bash", "-lc", "exec /bin/bash"]
