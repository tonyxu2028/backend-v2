<template>
  <div class="meedu-main-body">
    <back-bar class="mb-30" title="新建图文"></back-bar>
    <div class="float-left">
      <el-form ref="form" :model="topic" :rules="rules" label-width="200px">
        <div class="float-left">
          <el-form-item prop="category_id" label="所属分类">
            <div class="d-flex">
              <div>
                <el-select class="w-300px" v-model="topic.category_id">
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
                    p="demo–topic.category.index"
                    type="primary"
                    @click="$router.push({ name: 'TopicDemoCategory' })"
                >
                </p-link>
              </div>
            </div>
          </el-form-item>

          <el-form-item label="图文标题" prop="title">
            <el-input v-model="topic.title" class="w-300px"></el-input>
          </el-form-item>

          <el-form-item label="上架时间" prop="published_at">
            <div class="d-flex">
              <div>
                <el-date-picker
                    style="width: 300px"
                    v-model="topic.published_at"
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

          <el-form-item prop="context" label="内容">
            <div class="w-800px">
              <quill-editor
                  :height="800"
                  v-model="topic.context"
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

export default {
  components: {
    QuillEditor,
  },
  data() {
    return {
      topic: {
        published_at: null,
        title: null,
        category_id: null,
        context: null,
      },
      rules: {
        category_id: [
          {
            required: true,
            message: "分类不能为空",
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
        title: [
          {
            required: true,
            message: "标题名不能为空",
            trigger: "blur",
          },
        ],
        context: [
          {
            required: true,
            message: "内容不能为空",
            trigger: "blur",
          },
        ],
      },
      loading: false,
      categories: [],
    };
  },
  mounted() {
    this.params();
  },
  methods: {
    params() {
      this.$api.TopicDemo.Topic.Create().then((res) => {
        this.categories = res.data.categories;
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
      this.$api.TopicDemo.Topic.Store(this.topic)
          .then(() => {
            this.loading = false;
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
