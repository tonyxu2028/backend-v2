<template>
  <div class="meedu-main-body">
    <back-bar class="mb-30" title="编辑图文"></back-bar>

    <div class="float-left" v-if="topic">
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
          <el-form-item prop="thumb" label="封面">
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
                <helper-text text="最小单位“元”，不支持小数"></helper-text>
              </div>
            </div>
          </el-form-item>

          <el-form-item label="VIP免费" v-if="topic.charge > 0">
            <div class="d-flex">
              <div>
                <el-switch
                  v-model="topic.is_vip_free"
                  :active-value="1"
                  :inactive-value="0"
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
            v-if="topic.charge > 0"
          >
            <div class="d-flex w-800px">
              <mavon-editor
                v-if="topic.editor === 'MARKDOWN'"
                :height="500"
                :content="topic.free_content"
                @change="getfreecontent"
              ></mavon-editor>
              <quill-editor
                v-else
                :height="458"
                v-model="topic.free_content"
              ></quill-editor>
            </div>
          </el-form-item>

          <el-form-item
            prop="original_content"
            v-if="topic.charge > 0"
            label="付费内容"
          >
            <div class="d-flex w-800px">
              <mavon-editor
                v-if="topic.editor === 'MARKDOWN'"
                :content="topic.original_content"
                :height="500"
                @change="getcontent"
              ></mavon-editor>
              <quill-editor
                v-else
                v-model="topic.original_content"
                :height="458"
              ></quill-editor>
            </div>
          </el-form-item>
          <el-form-item prop="original_content" v-else label="文章内容">
            <div class="d-flex w-800px">
              <mavon-editor
                v-if="topic.editor === 'MARKDOWN'"
                :content="topic.original_content"
                :height="500"
                @change="getcontent"
              ></mavon-editor>
              <quill-editor
                v-else
                v-model="topic.original_content"
                :height="458"
              ></quill-editor>
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
  </div>
</template>
<script>
import MavonEditor from "@/components/md-editor";
import QuillEditor from "@/components/quill-editor";
import UploadImage from "@/components/upload-image";

export default {
  components: {
    MavonEditor,
    QuillEditor,
    UploadImage,
  },
  data() {
    return {
      id: this.$route.query.id,
      is_free: null,
      topic: null,
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
      original_charge: null,
    };
  },
  watch: {
    is_free(val) {
      if (val === 0) {
        this.topic.charge = this.original_charge;
      } else {
        this.topic.charge = 0;
      }
    },
  },
  mounted() {
    this.params();
    this.getDetail();
  },
  methods: {
    getcontent(pureContent, renderContent) {
      this.topic.original_content = pureContent;
      this.topic.render_content = renderContent;
    },
    getfreecontent(pureContent, renderContent) {
      this.topic.free_content = pureContent;
      this.topic.free_content_render = renderContent;
    },
    params() {
      this.$api.Course.Topic.Topic.Create().then((res) => {
        this.chapters = res.data;
      });
    },
    getDetail() {
      this.$api.Course.Topic.Topic.Detail(this.id).then((res) => {
        this.topic = res.data;
        this.original_charge = this.topic.charge;
        if (this.topic.charge > 0) {
          this.is_free = 0;
        } else {
          this.is_free = 1;
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
      if (this.topic.charge % 1 !== 0) {
        this.$message.error("图文价格必须为整数");
        return;
      }
      this.loading = true;
      if (this.topic.editor !== "MARKDOWN") {
        this.topic.render_content = this.topic.original_content;
        this.topic.free_content_render = this.topic.free_content;
      }
      this.$api.Course.Topic.Topic.Update(this.id, this.topic)
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
