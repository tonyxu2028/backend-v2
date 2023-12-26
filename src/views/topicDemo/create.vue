<template>
  <div class="meedu-main-body">
    <back-bar class="mb-30" title="新建图文"></back-bar>

    <div class="float-left">
      <el-form
        ref="form"
        class="float-left"
        :model="topic"
        :rules="rules"
        label-width="200px"
      >
        <div class="float-left">
          <el-form-item prop="cid" label="所属分类">
            <div class="d-flex">
              <div>
                <el-select class="w-300px" v-model="topic.cid">
                  <el-option
                    v-for="(item, index) in chapters"
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
                  @click="
                    $router.push({
                      name: 'TopicCategory',
                    })
                  "
                  type="primary"
                  p="addons.meedu_topics.category.list"
                ></p-link>
              </div>
            </div>
          </el-form-item>

          <el-form-item label="图文名称" prop="title">
            <el-input
              v-model="topic.title"
              class="w-300px"
              placeholder="请输入图文名称"
            ></el-input>
          </el-form-item>

          <el-form-item prop="thumb" label="图文封面">
            <upload-image
              v-model="topic.thumb"
              width="200"
              height="150"
              helper="建议尺寸400x300 宽高比4:3"
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

          <el-form-item label="价格" v-if="is_free === 0">
            <div class="d-flex">
              <div>
                <el-input
                  type="number"
                  placeholder="单位：元"
                  v-model="topic.charge"
                  class="w-300px"
                ></el-input>
              </div>
              <div class="ml-10">
                <helper-text text="请输入整数"></helper-text>
              </div>
            </div>
          </el-form-item>

          <el-form-item label="VIP免费" v-show="parseInt(topic.charge) > 0">
            <div class="d-flex">
              <div>
                <el-switch
                  v-model="topic.is_vip_free"
                  :active-value="true"
                  :inactive-value="false"
                >
                </el-switch>
              </div>
              <div class="ml-10">
                <helper-text
                  text="开启VIP免费的话，购买VIP会员的学员可无需购买直接观看文章。"
                ></helper-text>
              </div>
            </div>
          </el-form-item>

          <el-form-item label="上架时间" prop="sorted_at">
            <div class="d-flex">
              <div>
                <el-date-picker
                  style="width: 300px"
                  v-model="topic.sorted_at"
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
                  v-model="topic.is_show"
                  :active-value="0"
                  :inactive-value="1"
                >
                </el-switch>
              </div>
              <div class="ml-10">
                <helper-text text="打开后此图文在前台隐藏显示"></helper-text>
              </div>
            </div>
          </el-form-item>

          <el-form-item
            prop="free_content"
            label="免费内容"
            v-show="parseInt(topic.charge) > 0"
          >
            <change-editor
              :content="topic.free_content"
              class="w-100"
              :height="800"
              @change="getfreecontent"
            ></change-editor>
          </el-form-item>

          <el-form-item
            prop="original_content"
            v-show="parseInt(topic.charge) > 0"
            label="付费内容"
          >
            <change-editor
              :content="topic.original_content"
              class="w-100"
              :height="800"
              @change="getcontent"
            ></change-editor>
          </el-form-item>
          <el-form-item
            prop="original_content"
            v-show="!topic.charge || parseInt(topic.charge) === 0"
            label="文章内容"
          >
            <change-editor
              :content="topic.original_content"
              class="w-100"
              :height="800"
              @change="getcontent"
            ></change-editor>
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
  </div>
</template>
<script>
import UploadImage from "@/components/upload-image";
import ChangeEditor from "@/components/change-editor";

export default {
  components: {
    UploadImage,
    ChangeEditor,
  },
  data() {
    return {
      is_free: 0,
      topic: {
        cid: null,
        free_content: null,
        thumb: null,
        free_content_render: null,
        is_need_login: 0,
        is_show: 1,
        is_vip_free: 0,
        charge: null,
        title: null,
        sorted_at: null,
        original_content: null,
        render_content: null,
        editor: null,
      },
      rules: {
        cid: [
          {
            required: true,
            message: "分类不能为空",
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
        title: [
          {
            required: true,
            message: "图文名称不能为空",
            trigger: "blur",
          },
        ],
        original_content: [
          {
            required: true,
            message: "内容不能为空",
            trigger: "blur",
          },
        ],
        sorted_at: [
          {
            required: true,
            message: "上架时间不能为空",
            trigger: "blur",
          },
        ],
      },
      chapters: [],
      loading: false,
    };
  },
  watch: {
    is_free(val) {
      if (val === 1) {
        this.topic.charge = null;
      }
    },
  },
  mounted() {
    this.params();
  },
  methods: {
    getcontent: function (pureContent, renderContent) {
      this.topic.original_content = pureContent;
      this.topic.render_content = renderContent;
    },
    getfreecontent: function (pureContent, renderContent) {
      this.topic.free_content = pureContent;
      this.topic.free_content_render = renderContent;
    },
    params() {
      this.$api.Course.Topic.Topic.Create().then((res) => {
        this.chapters = res.data;
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
      if (this.is_free === 1) {
        this.topic.charge = 0;
      } else {
        if (!this.topic.charge || parseInt(this.topic.charge) <= 0) {
          this.$message.error("图文价格必须输入且大于0");
          return;
        }
      }
      if (this.topic.charge % 1 !== 0) {
        this.$message.error("图文价格必须为整数");
        return;
      }
      let localCurrent = this.$utils.getEditorKey();
      if (localCurrent === "markdown") {
        this.topic.editor = "MARKDOWN";
      } else {
        this.topic.editor = "FULLEDITOR";
      }

      this.loading = true;
      this.$api.Course.Topic.Topic.Store(this.topic)
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
