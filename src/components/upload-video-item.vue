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
              class="sel-button"
              @click="uploadByAliyunVod"
              >选择文件</el-button
            >
            <el-button
              v-show="isTenService"
              class="sel-button"
              @click="uploadByTencentVod"
              >选择文件</el-button
            >
            <el-button
              v-show="isLocalService"
              class="sel-button"
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
                <div class="progress-name">{{ item.file.name }}</div>
                <div class="progress-duration">
                  <duration-text :duration="item.duration"></duration-text>
                </div>
                <div class="progress-size">
                  {{ fileSizeConversion(item.size) }}M
                </div>
                <div class="progress-bar">
                  <span v-if="item.status === 5" class="error">{{
                    item.result
                  }}</span>
                  <template v-else>
                    <el-progress
                      type="line"
                      :text-inside="true"
                      text-color="#fff"
                      :stroke-width="14"
                      :percentage="item.progress"
                    ></el-progress>
                  </template>
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
import DurationText from "@/components/duration-text";

export default {
  components: {
    DurationText,
  },
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
  beforeDestroy() {
    let dropbox = document.getElementById("container");
    dropbox.removeEventListener("drop", this.eventDrop, false);
    dropbox.removeEventListener("dragleave", this.dragLeave, false);
    dropbox.removeEventListener("dragenter", this.dragEnter, false);
    dropbox.removeEventListener("dragover", this.dragOver, false);
  },
  methods: {
    dragEnter(ev) {
      let dropbox = document.getElementById("container");
      ev.stopPropagation();
      ev.preventDefault();
      dropbox.style.backgroundColor = "#fff";
    },
    dragOver(ev) {
      let dropbox = document.getElementById("container");
      ev.stopPropagation();
      ev.preventDefault();
      dropbox.style.backgroundColor = "#eee";
    },
    dragLeave(ev) {
      let dropbox = document.getElementById("container");
      ev.stopPropagation();
      ev.preventDefault();
      dropbox.style.backgroundColor = "#fff";
    },
    cancelTask(result) {
      if (this.isLocalService) {
        var fileItem = result.up.getFile(result.fileId);
        fileItem && result.up.removeFile(fileItem);
      } else if (this.isAliService) {
        let index = this.localUploadFiles.findIndex(
          (o) => o.id === result.fileId
        );
        index && this.upload.aliyun.cancelFile(index);
        index && this.upload.aliyun.deleteFile(index);
      } else if (this.isTenService) {
        if (!result.up) {
          this.$message.warning("请稍后取消");
          return;
        }
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
      dropbox.addEventListener("dragleave", this.dragLeave, false);
      dropbox.addEventListener("dragenter", this.dragEnter, false);
      dropbox.addEventListener("dragover", this.dragOver, false);
    },
    getVideoDuration(type, file, uploader, up) {
      var url = "";
      if (type === "local") {
        url = URL.createObjectURL(file.getNative());
      } else {
        url = URL.createObjectURL(file);
      }
      var audioElement = new Audio(url);
      var duration = 0;
      audioElement.addEventListener("loadedmetadata", (_event) => {
        duration = audioElement.duration;
        if (duration > 0 && type === "drop") {
          this.dropResult(duration, file);
        }
        if (duration > 0 && type === "local") {
          this.localResult(duration, file, uploader, up);
        }
        if (duration > 0 && type === "other") {
          this.otherResult(duration, file);
        }
      });
      audioElement.addEventListener("error", (_event) => {
        if (type === "local") {
          var fileItem = up.getFile(file.id);
          fileItem && up.removeFile(fileItem);
        }
        if (type === "other") {
          this.upload.loading = false;
        }
        this.$message.error("无法获取视频时长");
      });
    },
    dropResult(duration, file) {
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
          duration: duration,
          progress: 0,
          status: 1,
        });
        if (this.isAliService) {
          this.upload.service = "aliyun";
          this.pushAliyunUploadQueue(fileId, file);
        } else if (this.isTenService) {
          this.upload.service = "tencent";
          this.pushTencentUploadQueue(fileId, file);
        }
      }
    },
    localResult(duration, file, uploader, up) {
      this.uploading++;
      this.localUploadFiles.push({
        id: file.id,
        file: file,
        size: file.size,
        result: {
          fileId: file.id,
          up: up,
        },
        duration: duration,
        progress: 0,
        status: 1,
      });
      this.setUploadParam(uploader, false);
    },
    otherResult(duration, file) {
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
        duration: duration,
        progress: 0,
        status: 1,
      });
      if (this.upload.service === "aliyun") {
        this.pushAliyunUploadQueue(fileId, file);
      } else if (this.upload.service === "tencent") {
        this.pushTencentUploadQueue(fileId, file);
      }
    },
    eventDrop(e) {
      e.stopPropagation();
      e.preventDefault();
      // 修改拖中区域的背景色
      let dropbox = document.getElementById("container");
      dropbox.style.backgroundColor = "#fff";
      // 解析拖拽的文件
      let fileData = e.dataTransfer.files;
      let err = [];
      for (let i = 0; i < fileData.length; i++) {
        var file = fileData[i];
        let fileName = file.name;
        let lastName = fileName
          .substring(fileName.lastIndexOf("."))
          .toLowerCase();
        if (lastName === ".mp4") {
          this.getVideoDuration("drop", file);
        } else {
          err.push(`文件${fileName}不支持上传`);
        }
      }

      if (err.length > 0) {
        this.$message.error(err.join("|"));
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
        chunk_size: "4MB",
        multi_selection: true,
        multipart: true,
        headers: {
          Authorization: "Bearer " + that.$utils.getToken(),
          accept: "application/json",
        },
        url: url + "/backend/addons/LocalUpload/upload",
        filters: {
          mime_types: "video/mp4",
          max_file_size: "2048mb",
          prevent_duplicates: false, //不允许选取重复文件
        },
        init: {
          FilesAdded: (up, files) => {
            plupload.each(files, (file) => {
              this.getVideoDuration("local", file, uploader, up);
            });
          },
          BeforeUpload: (up, file) => {
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
            if (it) {
              it.result.up = up;
              it.status = 1;
              it.progress = parseInt(file.percent);
            }
          },
          FileUploaded: (up, file, info) => {
            this.upload.loading = false;
            this.uploading--;
            let it = this.localUploadFiles.find((o) => o.id === file.id);
            let data = JSON.parse(info.response);
            if (data.status === 0) {
              this.$message.success("上传成功");
              it.status = 7;
              it.result = null;
            } else {
              this.$message.error(data.message);
              it.status = 5;
              it.result = data.message;
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
      this.upload.aliyun = new window.AliyunUpload.Vod({
        partSize: 1048576 * 2, //块大小2m
        parallel: 5, //上传线程数
        retryCount: 3,
        retryDuration: 2,
        onUploadstarted: async (uploadInfo) => {
          try {
            let res = null;
            if (uploadInfo.videoId) {
              res = await this.$api.System.VideoUpload.AliyunTokenRefresh({
                video_id: uploadInfo.videoId,
              });
            } else {
              res = await this.$api.System.VideoUpload.AliyunTokenCreate({
                title: uploadInfo.file.name,
                filename: uploadInfo.file.name,
              });
            }

            this.upload.aliyun.setUploadAuthAndAddress(
              uploadInfo,
              res.data.upload_auth,
              res.data.upload_address,
              res.data.video_id
            );
          } catch (e) {
            this.$message.error(e.message || JSON.stringify(e));
          }
        },
        onUploadSucceed: (uploadInfo) => {
          this.upload.fileId = uploadInfo.videoId;
          let fileId = uploadInfo.videoInfo.CateId;
          let it = this.localUploadFiles.find((o) => o.id === fileId);
          if (it) {
            it.status = 7;
            it.result = null;
            this.uploadSuccessHandler(uploadInfo.videoId, "", fileId);
          }
        },
        onUploadFailed: (uploadInfo, code, message) => {
          this.uploading--;
          this.upload.loading = false;
          let fileId = uploadInfo.videoInfo.CateId;
          let it = this.localUploadFiles.find((o) => o.id === fileId);
          if (it) {
            it.status = 5;
            it.result = message;
            this.uploadFailHandler(message);
          }
        },
        onUploadProgress: (uploadInfo, totalSize, loadedPercent) => {
          let fileId = uploadInfo.videoInfo.CateId;
          let it = this.localUploadFiles.find((o) => o.id === fileId);
          if (it) {
            it.status = 1;
            it.progress = parseInt(loadedPercent * 100);
          }
        },
        onUploadTokenExpired: async (uploadInfo) => {
          try {
            let res = await this.$api.System.VideoUpload.AliyunTokenRefresh({
              video_id: uploadInfo.videoId,
            });
            this.upload.aliyun.resumeUploadWithAuth(res.data.upload_auth);
          } catch (e) {
            this.$message.error(e.message || JSON.stringify(e));
          }
        },
      });
    },
    uploadByAliyunVod() {
      if (this.upload.loading) {
        return;
      }
      this.upload.service = "aliyun";
      this.$refs["video-file"].click();
    },
    uploadByTencentVod() {
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
        this.getVideoDuration("other", files[i]);
      }
    },
    pushAliyunUploadQueue(fileId, file) {
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
    pushTencentUploadQueue(fileId, file) {
      const tcVod = new TcVod({
        getSignature: async () => {
          try {
            let res = await this.$api.System.VideoUpload.TencentToken();
            return res.data.signature;
          } catch (e) {
            this.$message.error(e.message || JSON.stringify(e));
          }
        },
      });
      const uploader = tcVod.upload({
        mediaFile: file,
      });
      uploader.on("media_progress", (info) => {
        let it = this.localUploadFiles.find((o) => o.id === fileId);
        if (it) {
          it.result.up = uploader;
          it.status = 1;
          it.progress = parseInt(info.percent * 100);
        }
      });
      uploader
        .done()
        .then((doneResult) => {
          this.upload.fileId = doneResult.fileId;
          this.uploadSuccessHandler(doneResult.fileId, "", fileId);
        })
        .catch((err) => {
          this.uploading--;
          let it = this.localUploadFiles.find((o) => o.id === fileId);
          if (it) {
            it.status = 5;
            it.result = err.message;
            this.uploadFailHandler(err.message);
          }
        });
    },
    uploadFailHandler(msg, fileID) {
      this.upload.loading = false;
      this.upload.fileId = null;
      this.$refs["video-file"].value = null;

      this.$message.error(msg);
    },
    uploadSuccessHandler(fileId, thumb, id) {
      this.uploading--;
      let it = this.localUploadFiles.find((o) => o.id === id);
      it.status = 7;
      it.result = null;
      this.upload.loading = false;
      this.$api.Media.Video.Store({
        title: it.file.name,
        duration: it.duration,
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
    },
    destory(item) {
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
.sel-button {
  background: #ecf5ff;
  border-color: #b3d8ff;
  color: #409eff;
}
.sel-button:hover {
  color: #ffffff;
  background-color: #409eff;
  border-color: #409eff;
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
          flex: 1;
          height: 14px;
          font-size: 14px;
          font-weight: 400;
          color: #333333;
          line-height: 14px;
          overflow: hidden; //溢出隐藏
          white-space: nowrap; //禁止换行
          text-overflow: ellipsis; //...
        }

        .progress-duration {
          width: 50px;
          margin-left: 15px;
          height: 14px;
          font-size: 14px;
          font-weight: 400;
          color: #333333;
          line-height: 14px;
        }

        .progress-size {
          width: 60px;
          margin-left: 15px;
          height: 14px;
          font-size: 14px;
          font-weight: 400;
          color: #333333;
          line-height: 14px;
        }
        .progress-bar {
          width: 100px;
          margin-top: -4px;
          margin-left: 15px;
          overflow: hidden; //溢出隐藏
          white-space: nowrap; //禁止换行
          text-overflow: ellipsis; //...
          .error {
            color: #ff4d4f;
            font-size: 14px;
            font-weight: 400;
            line-height: 14px;
          }
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
