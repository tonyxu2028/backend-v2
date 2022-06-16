<template>
  <div class="meedu-main-body">
    <back-bar class="mb-30" title="编辑学习路径"></back-bar>
    <div class="float-left">
      <el-form
        ref="form"
        class="float-left"
        :model="course"
        :rules="rules"
        label-width="200px"
      >
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
            <div class="ml-15">
              <p-link
                type="primary"
                text="分类管理"
                p="addons.learnPaths.category.list"
                @click="$router.push({ name: 'LearningPathCategories' })"
              >
              </p-link>
            </div>
          </div>
        </el-form-item>

        <el-form-item label="路径名称" prop="name">
          <el-input v-model="course.name" class="w-300px"></el-input>
        </el-form-item>

        <el-form-item prop="thumb" label="路径封面">
          <upload-image
            v-model="course.thumb"
            helper="长宽比4:3，建议尺寸：400x300像素"
            width="200"
            height="150"
            name="上传封面"
          ></upload-image>
        </el-form-item>

        <el-form-item label="原价" prop="original_charge">
          <el-input
            type="number"
            placeholder="单位：元"
            v-model="course.original_charge"
            class="w-300px"
          ></el-input>
        </el-form-item>

        <el-form-item label="现价" prop="charge">
          <el-input
            type="number"
            placeholder="单位：元"
            v-model="course.charge"
            class="w-300px"
          ></el-input>
        </el-form-item>

        <el-form-item label="上架时间">
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
                <helper-text text="上架时间越晚，排序越靠前"></helper-text>
              </div>
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
              <helper-text text="打开后学习路径在前台隐藏"></helper-text>
            </div>
          </div>
        </el-form-item>

        <el-form-item prop="desc" label="简短介绍">
          <el-input
            type="textarea"
            v-model="course.desc"
            class="w-800px"
            maxlength="150"
            rows="4"
            show-word-limit
            placeholder="简短介绍"
          ></el-input>
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
import UploadImage from "@/components/upload-image";

export default {
  components: {
    UploadImage,
  },
  data() {
    return {
      course: {
        id: this.$route.query.id,
        name: null,
        original_charge: null,
        charge: null,
        is_show: 1,
        thumb: null,
        category_id: null,
        published_at: null,
        desc: null,
      },
      rules: {
        category_id: [
          {
            required: true,
            message: "请选择分类",
            trigger: "blur",
          },
        ],
        name: [
          {
            required: true,
            message: "路径名不能为空",
            trigger: "blur",
          },
        ],
        charge: [
          {
            required: true,
            message: "现价不能为空",
            trigger: "blur",
          },
        ],
        original_charge: [
          {
            required: true,
            message: "原价不能为空",
            trigger: "blur",
          },
        ],
        thumb: [
          {
            required: true,
            message: "请上传封面",
            trigger: "blur",
          },
        ],
        desc: [
          {
            required: true,
            message: "描述不能为空",
            trigger: "blur",
          },
        ],
      },
      categories: [],
      loading: false,
    };
  },
  mounted() {
    this.params();
    this.detail();
  },
  methods: {
    params() {
      this.$api.Course.LearnPath.Path.Category.Create().then((res) => {
        let categories = res.data;
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
    detail() {
      this.$api.Course.LearnPath.Path.Detail(this.course.id).then((res) => {
        var data = res.data;
        this.course.name = data.name;
        this.course.charge = data.charge;
        this.course.original_charge = data.original_charge;
        this.course.is_show = data.is_show;
        this.course.thumb = data.thumb;
        this.course.category_id = data.category_id;
        this.course.published_at = data.published_at;
        this.course.desc = data.desc;
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
      this.$api.Course.LearnPath.Path.Update(this.course.id, this.course)
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
