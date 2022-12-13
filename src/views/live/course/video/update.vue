<template>
  <div class="meedu-main-body">
    <back-bar class="mb-30" title="编辑直播课程内容安排"></back-bar>
    <div class="float-left" v-if="course">
      <el-form
        ref="form"
        class="float-left"
        :model="course"
        :rules="rules"
        label-width="200px"
      >
        <el-form-item label="章节">
          <div class="d-flex">
            <div>
              <el-select class="w-300px" clearable v-model="course.chapter_id">
                <el-option
                  v-for="(item, index) in filterData.chapters"
                  :key="index"
                  :label="item.name"
                  :value="item.id"
                >
                </el-option>
              </el-select>
            </div>
            <div class="ml-10">
              <p-link
                text="章节管理"
                p="addons.Zhibo.course_chapter.list"
                type="primary"
                @click="
                  $router.push({
                    name: 'LiveCourseChapter',
                    query: { id: course.course_id },
                  })
                "
              ></p-link>
            </div>
          </div>
        </el-form-item>
        <el-form-item label="直播标题" prop="title">
          <el-input
            v-model="course.title"
            class="w-300px"
            placeholder="直播标题"
          ></el-input>
        </el-form-item>
        <el-form-item label="直播时间" prop="published_at">
          <el-date-picker
            style="width: 300px"
            v-model="course.published_at"
            type="datetime"
            format="yyyy-MM-dd HH:mm"
            value-format="yyyy-MM-dd HH:mm"
            placeholder="请选择日期"
          >
          </el-date-picker>
        </el-form-item>
        <el-form-item label="预估直播时长" prop="estimate_duration">
          <div class="d-flex">
            <div>
              <el-input
                v-model="course.estimate_duration"
                class="w-300px"
                placeholder="预估直播时长"
                type="number"
              >
                <template slot="append">分钟</template>
              </el-input>
            </div>
            <div class="ml-10">
              <helper-text
                text="学员观看直播超过此时长即代表学完此课时"
              ></helper-text>
            </div>
          </div>
        </el-form-item>
      </el-form>
      <div class="bottom-menus">
        <div class="bottom-menus-box">
          <div>
            <el-button @click="formValidate" :loading="loading" type="primary"
              >保存</el-button
            >
          </div>
          <div class="ml-24">
            <el-button @click="$router.back()">取消</el-button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
<script>
export default {
  data() {
    return {
      id: this.$route.query.id,
      course_id: this.$route.query.course_id,
      course: {
        course_id: this.$route.query.course_id,
        title: null,
        chapter_id: null,
        is_show: 1,
        published_at: null,
        estimate_duration: null,
      },
      rules: {
        // chapter_id: [
        //   {
        //     required: true,
        //     message: "请选择章节",
        //     trigger: "blur",
        //   },
        // ],
        title: [
          {
            required: true,
            message: "标题不能为空",
            trigger: "blur",
          },
        ],
        published_at: [
          {
            required: true,
            message: "直播时间不能为空",
            trigger: "blur",
          },
        ],
        estimate_duration: [
          {
            required: true,
            message: "预估直播时长不能为空",
            trigger: "blur",
          },
        ],
      },
      filterData: {
        chapters: [],
      },
      types: null,
      loading: false,
    };
  },
  mounted() {
    this.params();
    this.getDetail();
  },
  methods: {
    params() {
      this.$api.Course.Live.Course.Video.Create().then((res) => {
        var data = res.data.chapters[this.course_id];
        this.filterData.chapters = data;
      });
    },
    getDetail() {
      this.$api.Course.Live.Course.Video.Detail(this.id).then((res) => {
        this.course.title = res.data.title;
        if (res.data.chapter_id === 0) {
          this.course.chapter_id = null;
        } else {
          this.course.chapter_id = res.data.chapter_id;
        }
        this.course.published_at = res.data.published_at;
        this.course.estimate_duration = res.data.estimate_duration / 60;
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
      this.loading = true;
      this.$api.Course.Live.Course.Video.Update(this.id, {
        course_id: this.course.course_id,
        title: this.course.title,
        chapter_id: this.course.chapter_id,
        is_show: 1,
        published_at: this.course.published_at,
        estimate_duration: this.course.estimate_duration * 60,
      })
        .then(() => {
          this.$message.success(this.$t("common.success"));
          this.$router.back();
        })
        .catch((e) => {
          this.loading = false;
          this.$message.error(e.message);
        });
    },
  },
};
</script>
