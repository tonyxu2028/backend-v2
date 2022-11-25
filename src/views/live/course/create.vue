<template>
  <div class="meedu-main-body">
    <back-bar class="mb-30" title="新建直播课程"></back-bar>

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

    <div class="float-left mt-30">
      <el-form
        ref="form"
        class="float-left"
        :model="course"
        :rules="rules"
        label-width="200px"
      >
        <div class="float-left" v-show="tab.active === 'base'">
          <el-form-item label="所属分类" prop="category_id">
            <div class="d-flex">
              <div>
                <el-select class="w-300px" v-model="course.category_id">
                  <el-option
                    v-for="(item, index) in categories"
                    :key="index"
                    :label="item.name"
                    :value="item.id"
                  >
                  </el-option>
                </el-select>
              </div>
              <div class="ml-10">
                <p-link
                  text="分类管理"
                  type="primary"
                  @click="$router.push({ name: 'LiveCourseCategory' })"
                  p="addons.Zhibo.course_category.list"
                >
                </p-link>
              </div>
            </div>
          </el-form-item>

          <el-form-item label="讲师" prop="teacher_id">
            <div class="d-flex">
              <div>
                <el-select class="w-300px" v-model="course.teacher_id">
                  <el-option
                    v-for="(item, index) in teachers"
                    :key="index"
                    :label="item.name"
                    :value="item.id"
                  >
                  </el-option>
                </el-select>
              </div>
              <div class="ml-10">
                <p-link
                  text="讲师管理"
                  type="primary"
                  @click="$router.push({ name: 'LiveTeacher' })"
                  p="addons.Zhibo.teacher.list"
                >
                </p-link>
              </div>
            </div>
          </el-form-item>

          <el-form-item label="课程名" prop="title">
            <el-input
              v-model="course.title"
              class="w-300px"
              placeholder="课程名"
            ></el-input>
          </el-form-item>

          <el-form-item prop="thumb" label="课程封面">
            <upload-image
              v-model="course.thumb"
              width="200"
              height="150"
              name="上传课程封面"
              helper="推荐尺寸400x300 宽高比4:3"
            ></upload-image>
          </el-form-item>

          <el-form-item label="免费" prop="is_free">
            <div class="d-flex">
              <div>
                <el-switch
                  v-model="is_free"
                  :active-value="1"
                  :inactive-value="0"
                >
                </el-switch>
              </div>
            </div>
          </el-form-item>

          <el-form-item label="价格" prop="charge" v-if="is_free === 0">
            <div class="d-flex">
              <div>
                <el-input
                  v-model="course.charge"
                  placeholder="价格"
                  class="w-300px"
                ></el-input>
              </div>
              <div class="ml-10">
                <helper-text text="最小单位“元”，不支持小数"></helper-text>
              </div>
            </div>
          </el-form-item>

          <el-form-item label="上架时间" prop="published_at">
            <div class="d-flex">
              <div>
                <el-date-picker
                  style="width: 300px"
                  v-model="course.published_at"
                  type="datetime"
                  format="yyyy-MM-dd HH:mm"
                  value-format="yyyy-MM-dd HH:mm"
                  placeholder="请选择日期"
                >
                </el-date-picker>
              </div>
              <div class="ml-10">
                <helper-text text="上架时间越晚，排序越靠前"></helper-text>
              </div>
            </div>
          </el-form-item>

          <el-form-item label="隐藏">
            <div class="d-flex">
              <div>
                <el-switch
                  v-model="course.is_show"
                  :active-value="0"
                  :inactive-value="1"
                >
                </el-switch>
              </div>
              <div class="ml-10">
                <helper-text text="打开后此直播课在前台隐藏显示"></helper-text>
              </div>
            </div>
          </el-form-item>

          <el-form-item label="会员免费" v-if="is_free === 0">
            <div class="d-flex">
              <div>
                <el-switch
                  v-model="course.vip_can_view"
                  :active-value="1"
                  :inactive-value="0"
                >
                </el-switch>
              </div>
              <div class="ml-10">
                <helper-text
                  text="如果启用会员免费那么购买VIP会员的学员将可以无需购买直接观看直播。"
                ></helper-text>
              </div>
            </div>
          </el-form-item>

          <el-form-item label="简短介绍" prop="short_description">
            <el-input
              type="textarea"
              show-word-limit
              maxlength="150"
              v-model="course.short_description"
              class="w-800px"
              rows="3"
            ></el-input>
          </el-form-item>

          <el-form-item label="详细介绍" prop="original_desc">
            <div class="w-800px">
              <quill-editor
                :height="800"
                v-model="course.original_desc"
              ></quill-editor>
            </div>
          </el-form-item>
        </div>

        <div class="float-left" v-show="tab.active === 'dev'">
          <el-form-item label="播放封面">
            <div class="d-flex">
              <div>
                <upload-image
                  v-model="course.poster"
                  :can-clear="true"
                  width="400"
                  height="166.7"
                  name="上传播放封面"
                  helper="播放封面是在进入直播时播放器显示的图片。推荐尺寸：1200x500"
                ></upload-image>
              </div>
            </div>
          </el-form-item>
        </div>
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
    <el-dialog
      :visible.sync="visible"
      width="500px"
      @close="$router.replace({ name: 'LiveCourse' })"
    >
      <div class="text-center">
        <span>新建直播课成功，请在课程中添加直播排课吧！</span>
      </div>
      <span slot="footer" class="dialog-footer">
        <el-button @click="$router.replace({ name: 'LiveCourse' })"
          >暂不排课</el-button
        >
        <el-button @click="goVideo" type="primary">立即排课</el-button>
      </span>
    </el-dialog>
  </div>
</template>
<script>
import UploadImage from "@/components/upload-image";
import QuillEditor from "@/components/quill-editor";

export default {
  components: {
    UploadImage,
    QuillEditor,
  },
  data() {
    return {
      is_free: 0,
      course: {
        category_id: null,
        is_show: 1,
        charge: null,
        original_desc: null,
        render_desc: null,
        short_description: null,
        poster: null,
        teacher_id: null,
        published_at: null,
        vip_can_view: 0,
        title: null,
        thumb: null,
      },
      rules: {
        title: [
          {
            required: true,
            message: "课程名不能为空",
            trigger: "blur",
          },
        ],
        category_id: [
          {
            required: true,
            message: "请选择分类",
            trigger: "blur",
          },
        ],
        teacher_id: [
          {
            required: true,
            message: "请选择讲师",
            trigger: "blur",
          },
        ],
        charge: [
          {
            required: true,
            message: "价格不能为空",
            trigger: "blur",
          },
        ],
        short_description: [
          {
            required: true,
            message: "简短介绍不能为空",
            trigger: "blur",
          },
        ],
        published_at: [
          {
            required: true,
            message: "请选择上架时间",
            trigger: "blur",
          },
        ],
        thumb: [
          {
            required: true,
            message: "请上传课程封面",
            trigger: "blur",
          },
        ],
        original_desc: [
          {
            required: true,
            message: "请输入详细介绍",
            trigger: "blur",
          },
        ],
      },
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
      types: null,
      categories: [],
      teachers: [],
      loading: false,
      visible: false,
    };
  },
  watch: {
    is_free(val) {
      if (val === 1) {
        this.course.charge = 0;
        this.course.vip_can_view = 0;
      }
    },
  },
  mounted() {
    this.create();
  },
  methods: {
    create() {
      this.$api.Course.Live.Course.Create().then((res) => {
        var data = res.data;
        this.teachers = data.teachers;
        let categories = data.categories;
        let box = [];
        for (let i = 0; i < categories.length; i++) {
          if (categories[i].children.length > 0) {
            box.push(categories[i]);
            let children = categories[i].children;
            for (let j = 0; j < children.length; j++) {
              children[j].name = "|----" + children[j].name;
              box.push(children[j]);
            }
          } else {
            box.push(categories[i]);
          }
        }
        this.categories = box;
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
      if (this.course.charge == 0) {
        this.course.vip_can_view = 0;
      }
      this.course.render_desc = this.course.original_desc;
      this.$api.Course.Live.Course.Store(this.course)
        .then(() => {
          this.loading = false;
          this.visible = true;
        })
        .catch((e) => {
          this.loading = false;
          this.$message.error(e.message);
        });
    },
    goVideo() {
      this.$api.Course.Live.Course.List({
        page: 1,
        size: 1,
        sort: "id",
        order: "desc",
      }).then((res) => {
        this.$router.replace({
          name: "LiveCourseVideo",
          query: { id: res.data.data.data[0].id },
        });
      });
    },
  },
};
</script>
