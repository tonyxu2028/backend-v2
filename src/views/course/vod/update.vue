<template>
  <div class="meedu-main-body">
    <back-bar class="mb-30" title="编辑录播课程"></back-bar>
    <div class="float-left" v-if="course">
      <el-form ref="form" :model="course" :rules="rules" label-width="200px">
        <div class="float-left">
          <el-form-item prop="category_id" label="所属分类">
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
              <div class="ml-15">
                <p-link
                  text="分类管理"
                  p="courseCategory"
                  type="primary"
                  @click="$router.push({ name: 'CourseCategories' })"
                >
                </p-link>
              </div>
            </div>
          </el-form-item>

          <el-form-item label="课程名称" prop="title">
            <el-input v-model="course.title" class="w-300px"></el-input>
          </el-form-item>

          <el-form-item label="课程免费" prop="is_free">
            <div class="d-flex">
              <div>
                <el-switch
                  v-model="course.is_free"
                  :active-value="1"
                  :inactive-value="0"
                >
                </el-switch>
              </div>
              <div class="ml-10">
                <helper-text text="打开后课程免费学习"></helper-text>
              </div>
            </div>
          </el-form-item>

          <el-form-item
            label="课程价格"
            prop="charge"
            v-if="course.is_free === 0"
          >
            <div class="d-flex">
              <div>
                <el-input
                  type="number"
                  placeholder="单位：元"
                  v-model="course.charge"
                  class="w-300px"
                ></el-input>
              </div>
              <div class="ml-15">
                <helper-text text="最小单位“元”，不支持小数"></helper-text>
              </div>
            </div>
          </el-form-item>

          <el-form-item prop="thumb" label="课程封面">
            <upload-image
              v-model="course.thumb"
              helper="长宽比4:3，建议尺寸：400x300像素"
              width="200"
              height="150"
              name="上传封面"
            ></upload-image>
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
              <div class="ml-15">
                <div class="helper-text">
                  <helper-text
                    text="上架时间越早，课程排序越靠后"
                  ></helper-text>
                </div>
              </div>
            </div>
          </el-form-item>

          <el-form-item label="隐藏课程">
            <div class="d-flex">
              <div>
                <el-switch
                  v-model="course.is_show"
                  :active-value="0"
                  :inactive-value="1"
                >
                </el-switch>
              </div>
              <div class="ml-15">
                <div class="helper-text">
                  <helper-text text="打开后课程在前台将隐藏显示"></helper-text>
                </div>
              </div>
            </div>
          </el-form-item>

          <el-form-item prop="short_description" label="简短介绍">
            <el-input
              class="w-800px"
              type="textarea"
              rows="4"
              maxlength="150"
              show-word-limit
              v-model="course.short_description"
              placeholder="请填写课程简单介绍"
            ></el-input>
          </el-form-item>

          <el-form-item prop="original_desc" label="详情介绍">
            <div class="w-800px">
              <quill-editor
                :height="400"
                v-model="course.original_desc"
              ></quill-editor>
            </div>
          </el-form-item>
        </div>
      </el-form>

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
    </div>
  </div>
</template>
<script>
import QuillEditor from "@/components/quill-editor";
import UploadImage from "@/components/upload-image";

export default {
  components: {
    QuillEditor,
    UploadImage,
  },
  data() {
    return {
      id: null,
      course: null,
      rules: {
        category_id: [
          {
            required: true,
            message: "分类不能为空",
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
        published_at: [
          {
            required: true,
            message: "上架时间不能为空",
            trigger: "blur",
          },
        ],
        // is_show: [
        //   {
        //     required: true,
        //     message: "请选择显示",
        //     trigger: "blur",
        //   },
        // ],
        title: [
          {
            required: true,
            message: "课程名不能为空",
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
        short_description: [
          {
            required: true,
            message: "简短介绍不能为空",
            trigger: "blur",
          },
        ],
        original_desc: [
          {
            required: true,
            message: "详细介绍不能为空",
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
          name: "订阅后可评论",
        },
      ],
      categories: [],
      loading: false,
    };
  },
  mounted() {
    this.id = this.$route.query.id;

    this.params();
    this.detail();
  },
  methods: {
    detail() {
      this.$api.Course.Vod.Detail(this.id).then((res) => {
        this.course = res.data;
      });
    },
    params() {
      this.$api.Course.Vod.Create().then((res) => {
        let categories = res.data.categories;
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
      if (this.course.charge % 1 !== 0) {
        this.$message.error("课程价格必须为整数");
        return;
      }
      if (this.course.is_free === 0 && parseInt(this.course.charge) === 0) {
        this.$message.error("课程未设置免费时价格应该大于0");
        return;
      }
      this.loading = true;
      this.course.render_desc = this.course.original_desc;
      if (this.course.is_free === 1) {
        this.course.charge = 0;
      }
      this.$api.Course.Vod.Update(this.course.id, this.course)
        .then(() => {
          this.$message.success(this.$t("common.success"));
          this.$router.push({ name: "Vod" });
        })
        .catch((e) => {
          this.loading = false;
          this.$message.error(e.message);
        });
    },
  },
};
</script>
