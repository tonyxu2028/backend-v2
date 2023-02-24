<template>
  <transition name="fade">
    <div class="upload-dialog-box">
      <div class="meedu-dialog-header">上传列表</div>
      <div class="meedu-dialog-body">
        <div class="float-left">
          <div id="container" class="input-box float-left mb-30">
            <div class="tit">拖入视频文件至此区域</div>
            <div class="info">支持多个视频同时上传 / 仅支持mp4格式</div>
            <el-button
              v-show="isAliService"
              type="primary"
              :disabled="upload.loading"
              plain
              @click="uploadAliyunVod"
              >选择文件</el-button
            >
            <el-button
              v-show="isTenService"
              type="primary"
              :disabled="upload.loading"
              plain
              @click="uploadTencentVod"
              >选择文件</el-button
            >
            <el-button
              v-show="isLocalService"
              type="primary"
              :disabled="upload.loading"
              plain
              id="selectfiles"
              >选择文件</el-button
            >
          </div>
          <div class="process-box">
            <template v-if="localUploadFiles.length > 0">
              <div
                class="progress-item"
                v-for="item in localUploadFiles"
                :key="item.id"
              >
                <p class="progress-name">{{ item.file.name }}</p>
                <p class="progress-size">
                  {{ fileSizeConversion(item.size) }}M
                </p>
                <div class="progress-bar">
                  <el-progress
                    type="line"
                    :stroke-width="8"
                    :percentage="item.progress"
                    :show-text="false"
                  ></el-progress>
                </div>
                <b class="progress-status">
                  <template v-if="item.status === 1">
                    <el-popconfirm
                      title="确认取消上传吗？"
                      @confirm="cancelTask(item.result)"
                    >
                      <el-link slot="reference" type="primary">取消</el-link>
                    </el-popconfirm>
                  </template>
                  <span v-else-if="item.status === 5" class="error">失败</span>
                  <span v-else-if="item.status === 7" class="success"
                    >成功</span
                  >
                </b>
              </div>
            </template>
          </div>

          <div style="display: none">
            <input
              type="file"
              accept="video/mp4"
              ref="video-file"
              @change="fileChange"
              multiple="true"
            />
            <video ref="video-play" @loadedmetadata="videoPlayEvt"></video>
          </div>
        </div>
      </div>
      <div class="meedu-dialog-footer">
        <el-button
          type="primary"
          @click="confirm"
          :loading="upload.loading || uploading > 0"
        >
          完 成
        </el-button>
      </div>
    </div>
  </transition>
</template>

<script>
import { mapState } from "vuex";
import TcVod from "vod-js-sdk-v6";
import plupload from "plupload";
import config from "@/js/config";

export default {
  components: {},
  props: ["show"],
  data() {
    return {
      radio: "",
      loading: false,
      upload: {
        // 阿里云obj
        aliyun: null,
        //plupload本地
        up: null,
        //腾讯云
        ten: null,
        // 上传服务商
        service: null,
        // 是否上传中
        loading: false,
        // 上传进度
        process: 0,
        // 本地视频文件信息
        file: {
          title: null,
          thumb: null,
          size: null,
        },
        // 上传成功视频文件id
        fileId: null,
      },
      localUploadFiles: [],
      uploading: false,
      selectedVideo: null,
    };
  },
  computed: {
    ...mapState(["user", "systemConfig"]),
    isLocalService() {
      return this.systemConfig.video.default_service === "local";
    },
    isTenService() {
      return this.systemConfig.video.default_service === "tencent";
    },
    isAliService() {
      return this.systemConfig.video.default_service === "aliyun";
    },
  },
  mounted() {
    this.aliyunInit();
    this.pluploadInit();
    this.multipleDragEvent();
  },
  methods: {
    cancelTask(result) {
      if (this.isLocalService) {
        var fileItem = result.up.getFile(result.fileId);
        fileItem && result.up.removeFile(fileItem);
      } else if (this.isAliService) {
        let index = this.localUploadFiles.findIndex(
          (o) => o.id === result.fileId
        );
        this.upload.aliyun.cancelFile(index);
      } else if (this.isTenService) {
        result.up.cancel();
      }

      this.localUploadFiles = this.localUploadFiles.filter((item) => {
        return item.id != result.fileId;
      });
      this.uploading--;
      if (this.uploading === 0) {
        this.upload.loading = false;
      }
    },
    initDropElement() {
      //阻止浏览器默认行为
      document.addEventListener(
        "dragleave",
        function (e) {
          e.preventDefault();
        },
        false
      );
      document.addEventListener(
        "drop",
        function (e) {
          e.preventDefault();
        },
        false
      );
      document.addEventListener(
        "dragenter",
        function (e) {
          e.preventDefault();
        },
        false
      );
      document.addEventListener(
        "dragover",
        function (e) {
          e.preventDefault();
        },
        false
      );
    },
    fileSizeConversion(byte) {
      var size = `${(byte / (1024 * 1024)).toFixed(2)}`;
      const sizeStr = `${size}`;
      const index = sizeStr.indexOf(".");
      const dou = sizeStr.substr(index + 1, 2);
      if (dou == "00") {
        return sizeStr.substring(0, index) + sizeStr.substr(index + 3, 2);
      }
      return size;
    },
    checkPermission(val) {
      return typeof this.user.permissions[val] !== "undefined";
    },
    confirm() {
      this.$emit("change");
    },
    videoPlayEvt() {
      let duration = this.$refs["video-play"].duration;
      this.upload.file.duration = duration;
    },
    multipleDragEvent() {
      let dropbox = document.getElementById("container");
      dropbox.addEventListener("drop", this.eventDrop, false);
      dropbox.addEventListener("dragleave", function (e) {
        e.stopPropagation();
        e.preventDefault();
        dropbox.style.backgroundColor = "#fff";
      });
      dropbox.addEventListener("dragenter", function (e) {
        e.stopPropagation();
        e.preventDefault();
        dropbox.style.backgroundColor = "#fff";
      });
      dropbox.addEventListener("dragover", function (e) {
        e.stopPropagation();
        e.preventDefault();
        dropbox.style.backgroundColor = "#eee";
      });
    },
    eventDrop(e) {
      let dropbox = document.getElementById("container");
      e.stopPropagation();
      e.preventDefault();
      let fileData = e.dataTransfer.files;
      dropbox.style.backgroundColor = "#fff";
      for (let i = 0; i < fileData.length; i++) {
        var file = fileData[i];
        let fileName = file.name;
        let pos = fileName.lastIndexOf(".");
        let lastName = fileName.substring(pos, fileName.length);
        if (lastName.toLowerCase() === ".mp4") {
          if (this.isLocalService) {
            this.upload.service = "local";
            this.upload.up.addFile(file, file.name);
          } else {
            this.uploading++;
            let fileId = Math.random() * 100 + file.name;
            this.localUploadFiles.push({
              id: fileId,
              file: file,
              size: file.size,
              result: {
                fileId: fileId,
                up: null,
              },
              progress: 0,
              status: 1,
            });
            if (this.isAliService) {
              this.upload.service = "aliyun";
              this.aliyunUploadHandle(fileId, file);
            } else if (this.isTenService) {
              this.upload.service = "tencent";
              this.tencentUploadHandle(fileId, file);
            }
          }
        } else {
          this.$message.error(
            lastName.toLowerCase().slice(1) + "格式不支持上传"
          );
        }
      }
    },
    pluploadInit() {
      if (!this.isLocalService) {
        return;
      }
      this.upload.service = "local";
      let that = this;
      let url = config.url;
      if (url.substr(-1, 1) === "/") {
        url = url.substr(0, url.length - 1);
      }
      var uploader = new plupload.Uploader({
        runtimes: "html5",
        browse_button: "selectfiles",
        container: document.getElementById("container"),
        chunk_size: "1MB",
        multi_selection: true,
        multipart: true,
        headers: {
          Authorization: "Bearer " + that.$utils.getToken(),
          accept: "application/json",
        },
        url: url + "/backend/addons/LocalUpload/upload",
        filters: {
          mime_types: "video/mp4",
          max_file_size: "1024mb",
          prevent_duplicates: false, //不允许选取重复文件
        },
        init: {
          PostInit: () => {},
          FilesAdded: (up, files) => {
            plupload.each(files, (file) => {
              this.uploading++;
              this.localUploadFiles.push({
                id: file.id,
                file: file,
                size: file.size,
                result: {
                  fileId: file.id,
                  up: null,
                },
                progress: 0,
                status: 1,
              });
            });
            this.setUploadParam(uploader, false);
          },
          BeforeUpload: (up, file) => {
            // 解析视频时长
            var url = URL.createObjectURL(file.getNative());
            var audioElement = new Audio(url);
            var duration = 0;
            audioElement.addEventListener("loadedmetadata", (_event) => {
              duration = audioElement.duration;
              up.setOption("multipart_params", {
                duration: duration,
              });
            });
          },
          FilesRemoved: (up, files) => {
            this.upload.loading = false;
          },
          UploadProgress: (up, file) => {
            let it = this.localUploadFiles.find((o) => o.id === file.id);
            it.result = { fileId: file.id, up: up };
            it.status = 1;
            it.progress = parseInt(file.percent);
          },
          FileUploaded: (up, file, info) => {
            this.upload.loading = false;
            this.uploading--;
            let it = this.localUploadFiles.find((o) => o.id === file.id);
            if (info.status === 200) {
              this.$message.success("上传成功");
              it.status = 7;
              it.result = null;
            } else if (info.status === 203) {
              this.$message.error(
                "上传到OSS成功，但是oss访问用户设置的上传回调服务器失败，失败原因是:" +
                  info.response
              );
              it.status = 5;
              it.result = null;
            } else {
              this.$message.error(info.response);
              it.status = 5;
              it.result = null;
            }
          },
          Error: (up, err) => {
            this.upload.loading = false;
            if (err.code == -600) {
              this.uploadFailHandle(
                "选择的文件太大了，重新设置一下上传的最大大小"
              );
            } else if (err.code == -601) {
              this.uploadFailHandle("选择的文件后缀不对");
            } else if (err.code == -602) {
              this.uploadFailHandle("这个文件已经上传过一遍了");
            } else {
              this.uploadFailHandle("Error xml:" + err.response);
            }
          },
        },
      });
      uploader.init();
      this.upload.up = uploader;
    },
    setUploadParam(up, ret) {
      this.upload.loading = true;
      up.start();
    },
    aliyunInit() {
      if (!this.isAliService) {
        return;
      }
      // 阿里云初始化
      this.upload.aliyun = new window.AliyunUpload.Vod({
        partSize: 1048576,
        parallel: 5,
        retryCount: 3,
        retryDuration: 2,
        onUploadstarted: (uploadInfo) => {
          if (uploadInfo.videoId) {
            this.$api.System.VideoUpload.AliyunTokenRefresh({
              video_id: uploadInfo.videoId,
            })
              .then((res) => {
                this.upload.aliyun.setUploadAuthAndAddress(
                  uploadInfo,
                  res.data.upload_auth,
                  res.data.upload_address,
                  res.data.video_id
                );
              })
              .catch((e) => {
                this.$message.error(e.message);
              });
          } else {
            this.$api.System.VideoUpload.AliyunTokenCreate({
              title: uploadInfo.file.name,
              filename: uploadInfo.file.name,
            })
              .then((res) => {
                this.upload.aliyun.setUploadAuthAndAddress(
                  uploadInfo,
                  res.data.upload_auth,
                  res.data.upload_address,
                  res.data.video_id
                );
              })
              .catch((e) => {
                this.$message.error(e.message);
              });
          }
        },
        onUploadSucceed: (uploadInfo) => {
          this.upload.fileId = uploadInfo.videoId;
          let fileId = uploadInfo.videoInfo.CateId;
          let it = this.localUploadFiles.find((o) => o.id === fileId);
          it.status = 7;
          it.result = null;
          this.uploadSuccess(uploadInfo.videoId, "", fileId);
        },
        onUploadFailed: (uploadInfo, code, message) => {
          this.uploading--;
          this.upload.loading = false;
          let fileId = uploadInfo.videoInfo.CateId;
          let it = this.localUploadFiles.find((o) => o.id === fileId);
          it.status = 5;
          it.result = null;
          this.uploadFailHandle(
            "视频上到阿里云失败传失败，错误信息：" + message + ":code:" + code
          );
        },
        onUploadProgress: (uploadInfo, totalSize, loadedPercent) => {
          let fileId = uploadInfo.videoInfo.CateId;
          let it = this.localUploadFiles.find((o) => o.id === fileId);
          it.result = { fileId: fileId, up: null };
          it.status = 1;
          it.progress = parseInt(loadedPercent * 100);
        },
        onUploadTokenExpired: (uploadInfo) => {
          this.$api.System.VideoUpload.AliyunTokenRefresh({
            video_id: uploadInfo.videoId,
          })
            .then((res) => {
              this.upload.aliyun.resumeUploadWithAuth(res.data.upload_auth);
            })
            .catch((e) => {
              this.$message.error(e.message);
            });
        },
      });
    },
    uploadAliyunVod() {
      if (this.upload.loading) {
        return;
      }
      this.upload.service = "aliyun";
      this.$refs["video-file"].click();
    },
    uploadTencentVod() {
      if (this.upload.loading) {
        return;
      }
      this.upload.service = "tencent";
      this.$refs["video-file"].click();
    },
    fileChange(e) {
      let files = e.target.files;
      if (files.length === 0) {
        return;
      }

      this.upload.loading = true;
      for (var i = 0; i < files.length; i++) {
        var file = files[i];
        this.uploading++;
        let fileId = Math.random() * 100 + file.name;
        this.localUploadFiles.push({
          id: fileId,
          file: file,
          size: file.size,
          result: {
            fileId: fileId,
            up: null,
          },
          progress: 0,
          status: 1,
        });
        if (this.upload.service === "aliyun") {
          this.aliyunUploadHandle(fileId, file);
        } else if (this.upload.service === "tencent") {
          this.tencentUploadHandle(fileId, file);
        }
      }
    },
    aliyunUploadHandle(fileId, file) {
      this.upload.aliyun.addFile(
        file,
        null,
        null,
        null,
        JSON.stringify({
          Vod: { CateId: fileId },
        })
      );
      this.upload.aliyun.startUpload();
    },
    tencentUploadHandle(fileId, file) {
      const tcVod = new TcVod({
        getSignature: () => {
          return this.$api.System.VideoUpload.TencentToken()
            .then((res) => {
              return res.data.signature;
            })
            .catch((e) => {
              this.$message.error(e.message);
            });
        },
      });

      const uploader = tcVod.upload({
        mediaFile: file,
      });

      uploader.on("media_progress", (info) => {
        let it = this.localUploadFiles.find((o) => o.id === fileId);
        it.result = { fileId: fileId, up: uploader };
        it.status = 1;
        it.progress = parseInt(info.percent * 100);
      });

      // 回调结果说明
      // type doneResult = {
      //   fileId: string,
      //   video: {
      //     url: string
      //   },
      //   cover: {
      //     url: string
      //   }
      // }
      uploader
        .done()
        .then((doneResult) => {
          this.upload.fileId = doneResult.fileId;
          this.uploadSuccess(doneResult.fileId, "", fileId);
        })
        .catch((err) => {
          this.uploading--;
          let it = this.localUploadFiles.find((o) => o.id === fileId);
          it.status = 5;
          it.result = null;
          this.uploadFailHandle("上传视频到腾讯云点播错误");
        });
      this.upload.ten = uploader;
    },
    uploadFailHandle(msg) {
      this.upload.loading = false;
      this.upload.fileId = null;
      this.$refs["video-file"].value = null;

      this.$message.error(msg);
    },
    uploadSuccess(fileId, thumb, id) {
      this.uploading--;
      let it = this.localUploadFiles.find((o) => o.id === id);
      it.status = 7;
      it.result = null;
      this.upload.loading = false;
      // 解析视频时长
      var url = URL.createObjectURL(it.file);
      var audioElement = new Audio(url);
      var duration = 0;
      audioElement.addEventListener("loadedmetadata", (_event) => {
        duration = audioElement.duration;
        this.$api.Media.Video.Store({
          title: it.file.name,
          duration: duration,
          thumb: thumb,
          size: it.size,
          storage_driver: this.upload.service,
          storage_file_id: fileId,
        })
          .then((res) => {
            this.selectedVideo = res.data;
            this.$message.success("上传成功");
          })
          .catch((e) => {
            this.$message.error(e.message);
          });
      });
    },
    destory(item) {
      //点击确定按钮的操作
      if (this.loading) {
        return;
      }
      this.loading = true;
      let ids = [];
      ids.push(item);
      this.$api.Media.Video.Destroy({
        ids: ids,
      })
        .then(() => {
          this.loading = false;
          this.$message.success(this.$t("common.success"));
          this.getData();
        })
        .catch((e) => {
          this.loading = false;
          this.$message.error(e.message);
        });
    },
    destoryLocal(item) {
      //点击确定按钮的操作
      if (this.loading) {
        return;
      }
      this.loading = true;

      this.$api.System.VideoUpload.Destroy(item)
        .then(() => {
          this.loading = false;
          this.$message.success(this.$t("common.success"));
          this.getData();
        })
        .catch((e) => {
          this.loading = false;
          this.$message.error(e.message);
        });
    },
  },
};
</script>

<style lang="less" scoped>
.el-button--primary:hover {
  color: #fff;
}
.upload-dialog-box {
  position: absolute;
  top: 50%;
  left: 50%;
  width: 800px;
  height: 600px;
  margin-top: -300px;
  margin-left: -400px;
  background-color: white;
  border-radius: 8px;
  animation: scaleBig 0.3s;
  .meedu-dialog-header {
    width: 100%;
    height: auto;
    float: left;
    box-sizing: border-box;
    padding: 19px 30px 30px 30px;
    font-size: 18px;
    font-weight: 500;
    color: #333333;
    line-height: 18px;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .meedu-dialog-body {
    width: 100%;
    height: auto;
    float: left;

    .input-box {
      width: 740px;
      height: 159px;
      border-radius: 8px;
      border: 2px dashed rgba(0, 0, 0, 0.15);
      box-sizing: border-box;
      margin-left: 30px;
      margin-right: 30px;
      display: flex;
      flex-direction: column;
      align-items: center;
      position: relative;
      .tit {
        height: 25px;
        font-size: 18px;
        font-weight: 600;
        color: #333333;
        line-height: 25px;
        margin-top: 20px;
        margin-bottom: 15px;
      }
      .info {
        height: 14px;
        font-size: 14px;
        font-weight: 400;
        color: #999999;
        line-height: 14px;
        margin-bottom: 25px;
      }
    }
    .process-box {
      width: 100%;
      height: 273px;
      float: left;
      overflow-y: auto;
      box-sizing: border-box;
      padding-left: 30px;
      padding-right: 30px;
      .progress-item {
        width: 100%;
        display: flex;
        flex-direction: row;
        align-items: center;
        margin-bottom: 30px;
        .progress-name {
          width: 400px;
          height: 14px;
          font-size: 14px;
          font-weight: 400;
          color: #333333;
          line-height: 14px;
          overflow: hidden; //溢出隐藏
          white-space: nowrap; //禁止换行
          text-overflow: ellipsis; //...
        }
        .progress-size {
          flex: 1;
          margin-left: 30px;
          height: 14px;
          font-size: 14px;
          font-weight: 400;
          color: #333333;
          line-height: 14px;
        }
        .progress-bar {
          width: 100px;
          margin-left: 30px;
        }
        .progress-status {
          width: 56px;
          height: 14px;
          font-size: 14px;
          font-weight: 400;
          line-height: 14px;
          margin-left: 30px;
          text-align: right;
          .link {
            color: #3ca7fa;
            cursor: pointer;
            &:hover {
              opacity: 0.8;
            }
          }
          .success {
            color: #04c877;
          }
          .error {
            color: #ff4d4f;
          }
        }
      }
    }
  }

  .meedu-dialog-footer {
    width: 100%;
    height: auto;
    float: left;
    box-sizing: border-box;
    padding: 15px 30px;
    border-top: 1px solid #e5e5e5;
  }
}
</style>
<style lang="less">
.el-popconfirm__main {
  margin-block-start: 1em;
  margin-block-end: 1em;
  margin-inline-start: 0px;
  margin-inline-end: 0px;
}
</style>
