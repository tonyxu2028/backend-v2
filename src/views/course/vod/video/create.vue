<template>
  <div class="meedu-main-body">
    <back-bar class="mb-30" title="添加课时"></back-bar>

    <div class="center-tabs mb-30">
      <div>
        <el-tabs v-model="tab.active">
          <el-tab-pane
            :label="item.name"
            :name="item.key"
            v-for="(item, index) in tab.list"
            :key="index"
          ></el-tab-pane>
        </el-tabs>
      </div>
    </div>

    <div class="float-left" v-if="course">
      <el-form ref="form" :model="video" :rules="rules" label-width="200px">
        <div class="float-left" v-show="tab.active === 'base'">
          <el-form-item label="上传课时">
            <el-button type="primary" @click="showUploadVideoWin = true">
              <span>选择视频</span>
              <span class="ml-10" v-if="tit">{{
                tit.replace(".m3u8", "").replace(".mp4", "")
              }}</span>
            </el-button>
          </el-form-item>

          <el-form-item label="课时名称" prop="title">
            <el-input
              v-model="video.title"
              class="w-300px"
              placeholder="请输入课时名称"
            ></el-input>
          </el-form-item>

          <el-form-item label="课时时长" prop="duration">
            <div class="d-flex">
              <div>
                <input-duration
                  :disabled="false"
                  v-model="video.duration"
                ></input-duration>
              </div>
              <div class="ml-10">
                <helper-text
                  text="后台会根据课时时长统计学员学习进度"
                ></helper-text>
              </div>
            </div>
          </el-form-item>

          <el-form-item label="可试看时长" v-if="course.is_free !== 1">
            <div class="d-flex">
              <div>
                <input-duration
                  :disabled="false"
                  v-model="video.free_seconds"
                ></input-duration>
              </div>

              <div class="ml-10">
                <helper-text
                  text="设置此课时免费试看时长（此配置对本地存储或URL视频无效）"
                ></helper-text>
              </div>
            </div>
          </el-form-item>

          <el-form-item label="所属章节">
            <div class="d-flex">
              <div>
                <el-select
                  class="w-300px"
                  filterable
                  clearable
                  v-model="video.chapter_id"
                  placeholder="请选择章节"
                >
                  <el-option
                    v-for="(item, index) in chapters"
                    :key="index"
                    :label="item.title"
                    :value="item.id"
                  >
                  </el-option>
                </el-select>
              </div>
              <div class="ml-10">
                <p-link
                  text="章节管理"
                  p="course_chapter"
                  @click="
                    $router.push({
                      name: 'CourseChapters',
                      query: { course_id: course_id },
                    })
                  "
                  type="primary"
                ></p-link>
              </div>
            </div>
          </el-form-item>

          <el-form-item label="上架时间" prop="published_at">
            <div class="d-flex">
              <div>
                <el-date-picker
                  style="width: 300px"
                  v-model="video.published_at"
                  type="datetime"
                  align="right"
                  placeholder="请选择日期"
                  value-format="yyyy-MM-dd HH:mm:ss"
                >
                </el-date-picker>
              </div>
              <div class="ml-10">
                <helper-text text="上架时间越早，课时排序越靠前"></helper-text>
              </div>
            </div>
          </el-form-item>
        </div>

        <div class="float-left" v-show="tab.active === 'dev'">
          <el-form-item label="禁止快进播放" prop="ban_drag">
            <div class="d-flex">
              <div>
                <el-switch
                  v-model="video.ban_drag"
                  :active-value="1"
                  :inactive-value="0"
                >
                </el-switch>
              </div>
              <div class="ml-10">
                <helper-text text="打开后学员学习此课时无法快进"></helper-text>
              </div>
            </div>
          </el-form-item>

          <el-form-item label="隐藏课时" prop="is_show">
            <div class="d-flex">
              <div>
                <el-switch
                  v-model="video.is_show"
                  :active-value="0"
                  :inactive-value="1"
                >
                </el-switch>
              </div>
              <div class="ml-10">
                <helper-text text="打开后课时在前台将隐藏显示"></helper-text>
              </div>
            </div>
          </el-form-item>

          <!-- <el-form-item label="评论开关" prop="comment_status">
            <el-select v-model="video.comment_status">
              <el-option
                v-for="(item, index) in comments"
                :key="index"
                :label="item.name"
                :value="item.id"
              >
              </el-option>
            </el-select>
          </el-form-item> -->

          <el-form-item label="阿里云视频文件ID" prop="aliyun_video_id">
            <el-input
              v-model="video.aliyun_video_id"
              class="w-300px"
              placeholder="阿里云视频文件ID"
            ></el-input>
          </el-form-item>

          <el-form-item label="腾讯云视频文件ID" prop="tencent_video_id">
            <el-input
              v-model="video.tencent_video_id"
              class="w-300px"
              placeholder="腾讯云视频文件ID"
            ></el-input>
          </el-form-item>

          <el-form-item label="视频URL" prop="url">
            <el-input
              v-model="video.url"
              class="w-300px"
              placeholder="视频URL"
            ></el-input>
          </el-form-item>
        </div>
      </el-form>
    </div>

    <div class="bottom-menus">
      <div class="bottom-menus-box">
        <div>
          <el-button @click="formValidate" :loading="loading" type="primary">
            保存
          </el-button>
        </div>
        <div class="ml-24">
          <el-button @click="$router.back()">取消</el-button>
        </div>
      </div>
    </div>

    <upload-video
      v-if="showUploadVideoWin"
      @close="showUploadVideoWin = false"
      @change="uploadVideoChange"
    ></upload-video>
  </div>
</template>
<script>
import InputDuration from "@/components/input-duration";
import UploadVideo from "@/components/upload-video";

export default {
  components: {
    InputDuration,
    UploadVideo,
  },
  data() {
    return {
      showUploadVideoWin: false,
      course_id: this.$route.query.course_id,
      course: null,
      tit: null,
      video: {
        course_id: this.$route.query.course_id,
        published_at: null,
        title: null,
        charge: null,
        is_show: 1,
        is_ban_sell: 1,
        ban_drag: 0,
        chapter_id: null,
        duration: null,
        free_seconds: 0,
        aliyun_video_id: null,
        short_description: null,
        tencent_video_id: null,
        url: null,
      },
      chapters: [],
      rules: {
        title: [
          {
            required: true,
            message: "视频名不能为空",
            trigger: "blur",
          },
        ],
        published_at: [
          {
            required: true,
            message: "上架时间不能为空",
            trigger: "blur",
          },
        ],
        duration: [
          {
            required: true,
            message: "视频时长不能为空",
            trigger: "blur",
          },
        ],
      },
      comments: [
        {
          id: 0,
          name: "关闭评论",
        },
        {
          id: 1,
          name: "所有人均可评论",
        },
        {
          id: 2,
          name: "购买后可评论",
        },
      ],
      loading: false,
      tab: {
        active: "base",
        list: [
          {
            name: "基础信息",
            key: "base",
          },
          {
            name: "可选信息",
            key: "dev",
          },
        ],
      },
    };
  },
  mounted() {
    this.getCreateParams();
    this.getCourse();
  },
  methods: {
    getCreateParams() {
      this.$api.Course.Vod.Videos.Create(this.course_id).then((res) => {
        this.chapters = res.data.chapters;
      });
    },
    getCourse() {
      this.$api.Course.Vod.Detail(this.course_id).then((res) => {
        this.course = res.data;
        if (this.course.is_free === 1) {
          this.video.charge = 0;
          this.video.free_seconds = 0;
        } else {
          this.video.charge = this.course.charge;
        }
      });
    },
    formValidate() {
      this.$refs["form"].validate((valid) => {
        if (valid) {
          this.confirm();
        }
      });
    },
    confirm() {
      if (this.loading) {
        return;
      }
      if (
        !this.video.url &&
        !this.video.aliyun_video_id &&
        !this.video.tencent_video_id
      ) {
        this.$message.error("请上传课程视频");
        return;
      }
      if (this.chapters.length > 0 && !this.video.chapter_id) {
        this.$message.error("请选择所属章节");
        return;
      }
      this.loading = true;
      this.$api.Course.Vod.Videos.Store(this.video)
        .then(() => {
          this.$message.success(this.$t("common.success"));
          this.$router.back();
        })
        .catch((e) => {
          this.loading = false;
          this.$message.error(e.message);
        });
    },
    uploadVideoChange(video) {
      this.video.duration = video.duration;

      if (video.storage_driver === "aliyun") {
        if (!this.video.title) {
          this.video.title = video.title
            .replace(".m3u8", "")
            .replace(".mp4", "");
        }
        this.tit = video.title;
        this.video.aliyun_video_id = video.storage_file_id;
        this.video.tencent_video_id = null;
        this.video.url = null;
      } else if (video.storage_driver === "tencent") {
        if (!this.video.title) {
          this.video.title = video.title
            .replace(".m3u8", "")
            .replace(".mp4", "");
        }
        this.tit = video.title;
        this.video.tencent_video_id = video.storage_file_id;
        this.video.aliyun_video_id = null;
        this.video.url = null;
      } else if (video.storage_driver === "local") {
        if (!this.video.title) {
          this.video.title = video.name
            .replace(".m3u8", "")
            .replace(".mp4", "");
        }
        this.$api.Resource.LocalVideosUrl(video.storage_file_id, {}).then(
          (res) => {
            this.tit = video.title;
            this.video.tencent_video_id = null;
            this.video.aliyun_video_id = null;
            this.video.url = res.data.url;
          }
        );
      }

      this.showUploadVideoWin = false;
    },
  },
};
</script>
