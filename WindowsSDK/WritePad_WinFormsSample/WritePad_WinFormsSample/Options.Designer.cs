namespace WritePad_WinFormsSample
{
    partial class Options
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.SeparateLetters = new System.Windows.Forms.CheckBox();
            this.DisableSegmentation = new System.Windows.Forms.CheckBox();
            this.AutoLearner = new System.Windows.Forms.CheckBox();
            this.AutoCorrector = new System.Windows.Forms.CheckBox();
            this.UserDictionary = new System.Windows.Forms.CheckBox();
            this.DictionaryOnly = new System.Windows.Forms.CheckBox();
            this.SuspendLayout();
            // 
            // SeparateLetters
            // 
            this.SeparateLetters.AutoSize = true;
            this.SeparateLetters.Location = new System.Drawing.Point(12, 13);
            this.SeparateLetters.Name = "SeparateLetters";
            this.SeparateLetters.Size = new System.Drawing.Size(171, 17);
            this.SeparateLetters.TabIndex = 0;
            this.SeparateLetters.Text = "Separate letters mode (PRINT)";
            this.SeparateLetters.UseVisualStyleBackColor = true;
            this.SeparateLetters.CheckedChanged += new System.EventHandler(this.SeparateLetters_CheckedChanged);
            // 
            // DisableSegmentation
            // 
            this.DisableSegmentation.AutoSize = true;
            this.DisableSegmentation.Location = new System.Drawing.Point(12, 37);
            this.DisableSegmentation.Name = "DisableSegmentation";
            this.DisableSegmentation.Size = new System.Drawing.Size(215, 17);
            this.DisableSegmentation.TabIndex = 1;
            this.DisableSegmentation.Text = "Disable word segmentation (single word)";
            this.DisableSegmentation.UseVisualStyleBackColor = true;
            this.DisableSegmentation.CheckedChanged += new System.EventHandler(this.DisableSegmentation_CheckedChanged);
            // 
            // AutoLearner
            // 
            this.AutoLearner.AutoSize = true;
            this.AutoLearner.Location = new System.Drawing.Point(12, 61);
            this.AutoLearner.Name = "AutoLearner";
            this.AutoLearner.Size = new System.Drawing.Size(144, 17);
            this.AutoLearner.TabIndex = 2;
            this.AutoLearner.Text = "Enable Automatic learner";
            this.AutoLearner.UseVisualStyleBackColor = true;
            this.AutoLearner.CheckedChanged += new System.EventHandler(this.AutoLearner_CheckedChanged);
            // 
            // AutoCorrector
            // 
            this.AutoCorrector.AutoSize = true;
            this.AutoCorrector.Location = new System.Drawing.Point(12, 85);
            this.AutoCorrector.Name = "AutoCorrector";
            this.AutoCorrector.Size = new System.Drawing.Size(126, 17);
            this.AutoCorrector.TabIndex = 3;
            this.AutoCorrector.Text = "Enable Autocorrector";
            this.AutoCorrector.UseVisualStyleBackColor = true;
            this.AutoCorrector.CheckedChanged += new System.EventHandler(this.AutoCorrector_CheckedChanged);
            // 
            // UserDictionary
            // 
            this.UserDictionary.AutoSize = true;
            this.UserDictionary.Location = new System.Drawing.Point(12, 109);
            this.UserDictionary.Name = "UserDictionary";
            this.UserDictionary.Size = new System.Drawing.Size(134, 17);
            this.UserDictionary.TabIndex = 4;
            this.UserDictionary.Text = "Enable User Dictionary";
            this.UserDictionary.UseVisualStyleBackColor = true;
            this.UserDictionary.CheckedChanged += new System.EventHandler(this.UserDictionary_CheckedChanged);
            // 
            // DictionaryOnly
            // 
            this.DictionaryOnly.AutoSize = true;
            this.DictionaryOnly.Location = new System.Drawing.Point(12, 133);
            this.DictionaryOnly.Name = "DictionaryOnly";
            this.DictionaryOnly.Size = new System.Drawing.Size(185, 17);
            this.DictionaryOnly.TabIndex = 5;
            this.DictionaryOnly.Text = "Recognize Dictionary Words Only";
            this.DictionaryOnly.UseVisualStyleBackColor = true;
            this.DictionaryOnly.CheckedChanged += new System.EventHandler(this.DictionaryOnly_CheckedChanged);
            // 
            // Options
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(331, 232);
            this.Controls.Add(this.DictionaryOnly);
            this.Controls.Add(this.UserDictionary);
            this.Controls.Add(this.AutoCorrector);
            this.Controls.Add(this.AutoLearner);
            this.Controls.Add(this.DisableSegmentation);
            this.Controls.Add(this.SeparateLetters);
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "Options";
            this.ShowIcon = false;
            this.ShowInTaskbar = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "Options";
            this.Load += new System.EventHandler(this.Options_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.CheckBox SeparateLetters;
        private System.Windows.Forms.CheckBox DisableSegmentation;
        private System.Windows.Forms.CheckBox AutoLearner;
        private System.Windows.Forms.CheckBox AutoCorrector;
        private System.Windows.Forms.CheckBox UserDictionary;
        private System.Windows.Forms.CheckBox DictionaryOnly;
    }
}